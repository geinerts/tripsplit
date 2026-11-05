import importlib.util
from pathlib import Path
import unittest

SPEC = importlib.util.spec_from_file_location('monitor_resources', Path(__file__).parents[1] / 'monitor_resources.py')
monitor = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(monitor)


class ResourceMonitorTest(unittest.TestCase):
    def sample(self, state, second, ram=86, idle=0, boot='boot'):
        return monitor.evaluate(state, second, boot, [1000 + second * 100, idle], ram)[0]

    def test_cpu_counters_and_invalid_samples(self):
        self.assertEqual(monitor.cpu_percent([100, 20], [200, 30]), 90)
        self.assertIsNone(monitor.cpu_percent(None, [100, 20]))
        self.assertIsNone(monitor.cpu_percent([200, 30], [100, 20]))
        self.assertIsNone(monitor.cpu_percent([100, 20], [100, 20]))

    def test_ram_alert_after_five_minutes_not_before(self):
        state = {}
        for second in range(0, 300, 60):
            self.assertEqual(self.sample(state, second), [])
        self.assertEqual(self.sample(state, 300), [('ram', 'alert', 86)])

    def test_cpu_needs_baseline_then_five_minutes(self):
        state = {}
        for second in range(0, 360, 60):
            self.assertEqual(self.sample(state, second, ram=30), [])
        self.assertEqual(self.sample(state, 360, ram=30), [('cpu', 'alert', 100)])

    def test_thresholds_are_strict_and_dip_resets_timer(self):
        state = {}
        for second in range(0, 600, 60):
            self.assertEqual(self.sample(state, second, ram=85, idle=second * 10), [])
        state = {}
        for second in [0, 60, 120, 180, 240]:
            self.sample(state, second)
        self.assertEqual(self.sample(state, 300, ram=85), [])
        # CPU is unrelated and stays high; acknowledge it to isolate RAM.
        state['cpu']['notified'] = True
        for second in [360, 420, 480, 540, 600]:
            self.assertEqual(self.sample(state, second), [])
        self.assertEqual(self.sample(state, 660), [('ram', 'alert', 86)])

    def test_no_repeat_until_recovery_and_new_incident(self):
        state = {}
        for second in range(0, 420, 60):
            events = self.sample(state, second)
            for key, kind, _ in events:
                state[key]['notified'] = kind == 'alert'
        self.assertEqual(self.sample(state, 420), [])
        events = self.sample(state, 480, ram=40, idle=6000)
        self.assertEqual(events, [('cpu', 'recovery', 0), ('ram', 'recovery', 40)])
        for key, _, _ in events:
            state[key]['notified'] = False
        for second in range(540, 840, 60):
            self.assertEqual(self.sample(state, second, idle=6000), [])
        self.assertEqual(len(self.sample(state, 840, idle=6000)), 2)

    def test_gap_or_reboot_does_not_count_as_high_load(self):
        for reboot in [False, True]:
            with self.subTest(reboot=reboot):
                state = {}
                for second in [0, 60, 120, 180, 240]:
                    self.sample(state, second)
                self.assertEqual(self.sample(state, 600, boot='new' if reboot else 'boot'), [])
                self.assertEqual(state['ram']['since'], 600)
                self.assertIsNone(state['cpu']['since'])

    def test_failed_delivery_remains_pending(self):
        state = {}
        for second in range(0, 300, 60):
            self.sample(state, second)
        self.assertIn(('ram', 'alert', 86), self.sample(state, 300))
        # No delivery acknowledgement: retry rather than silently lose alert.
        self.assertIn(('ram', 'alert', 86), self.sample(state, 360))


if __name__ == '__main__':
    unittest.main()
