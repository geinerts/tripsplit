import 'package:flutter_test/flutter_test.dart';
import 'package:tripsplit/features/workspace/data/datasources/workspace_remote_parsers.dart';

void main() {
  group('WorkspaceRemoteParsers.parseTripStatus', () {
    test('normalizes allowed statuses and defaults unknown to active', () {
      expect(WorkspaceRemoteParsers.parseTripStatus('active'), 'active');
      expect(WorkspaceRemoteParsers.parseTripStatus('settling'), 'settling');
      expect(WorkspaceRemoteParsers.parseTripStatus('archived'), 'archived');
      expect(WorkspaceRemoteParsers.parseTripStatus('ACTIVE'), 'active');
      expect(WorkspaceRemoteParsers.parseTripStatus('weird'), 'active');
      expect(WorkspaceRemoteParsers.parseTripStatus(null), 'active');
    });
  });

  group('WorkspaceRemoteParsers.parseSettlementStatus', () {
    test('normalizes settlement status and defaults unknown to suggested', () {
      expect(
        WorkspaceRemoteParsers.parseSettlementStatus('pending'),
        'pending',
      );
      expect(WorkspaceRemoteParsers.parseSettlementStatus('sent'), 'sent');
      expect(
        WorkspaceRemoteParsers.parseSettlementStatus('confirmed'),
        'confirmed',
      );
      expect(
        WorkspaceRemoteParsers.parseSettlementStatus('suggested'),
        'suggested',
      );
      expect(
        WorkspaceRemoteParsers.parseSettlementStatus('PENDING'),
        'pending',
      );
      expect(WorkspaceRemoteParsers.parseSettlementStatus('x'), 'suggested');
      expect(WorkspaceRemoteParsers.parseSettlementStatus(null), 'suggested');
    });
  });

  group('WorkspaceRemoteParsers.parseExpenseSplitMode', () {
    test('normalizes split mode and defaults unknown to equal', () {
      expect(WorkspaceRemoteParsers.parseExpenseSplitMode('equal'), 'equal');
      expect(WorkspaceRemoteParsers.parseExpenseSplitMode('exact'), 'exact');
      expect(
        WorkspaceRemoteParsers.parseExpenseSplitMode('percent'),
        'percent',
      );
      expect(WorkspaceRemoteParsers.parseExpenseSplitMode('shares'), 'shares');
      expect(WorkspaceRemoteParsers.parseExpenseSplitMode('foo'), 'equal');
      expect(WorkspaceRemoteParsers.parseExpenseSplitMode(null), 'equal');
    });
  });

  group('WorkspaceRemoteParsers.parseSettlement', () {
    test('sets isConfirmed true when status is confirmed', () {
      final settlement =
          WorkspaceRemoteParsers.parseSettlement(<String, dynamic>{
            'id': 10,
            'from_user_id': 1,
            'to_user_id': 2,
            'from': 'Alice',
            'to': 'Bob',
            'amount': 12.34,
            'status': 'confirmed',
            'is_confirmed': false,
            'can_mark_sent': false,
            'can_confirm_received': false,
          });

      expect(settlement.id, 10);
      expect(settlement.status, 'confirmed');
      expect(settlement.isConfirmed, isTrue);
      expect(settlement.canMarkSent, isFalse);
      expect(settlement.canConfirmReceived, isFalse);
    });

    test('keeps action flags and default status mapping', () {
      final settlement =
          WorkspaceRemoteParsers.parseSettlement(<String, dynamic>{
            'from_user_id': 3,
            'to_user_id': 4,
            'from': 'Carol',
            'to': 'Dave',
            'amount': 9.99,
            'status': 'unexpected',
            'can_mark_sent': true,
            'can_confirm_received': true,
            'is_confirmed': true,
          });

      expect(settlement.status, 'suggested');
      expect(settlement.canMarkSent, isTrue);
      expect(settlement.canConfirmReceived, isTrue);
      expect(settlement.isConfirmed, isTrue);
    });
  });

  group('WorkspaceRemoteParsers.parseExpense', () {
    test('uses explicit category and defaults missing category to other', () {
      final withCategory =
          WorkspaceRemoteParsers.parseExpense(<String, dynamic>{
            'id': 12,
            'amount': 44.5,
            'category': 'fuel',
            'note': 'Gas station',
            'expense_date': '2026-03-12',
            'split_mode': 'equal',
            'paid_by_id': 5,
            'paid_by_nickname': 'Alex',
            'participants': const <Map<String, dynamic>>[],
          });
      expect(withCategory.category, 'fuel');

      final defaulted = WorkspaceRemoteParsers.parseExpense(<String, dynamic>{
        'id': 13,
        'amount': 10,
        'note': '',
        'expense_date': '2026-03-13',
        'split_mode': 'equal',
        'paid_by_id': 5,
        'paid_by_nickname': 'Alex',
        'participants': const <Map<String, dynamic>>[],
      });
      expect(defaulted.category, 'other');
    });

    test('parses optional receipt thumbnail url', () {
      final expense = WorkspaceRemoteParsers.parseExpense(<String, dynamic>{
        'id': 14,
        'amount': 15,
        'category': 'food',
        'note': 'Lunch',
        'expense_date': '2026-03-13',
        'split_mode': 'equal',
        'paid_by_id': 5,
        'paid_by_nickname': 'Alex',
        'receipt_url': 'https://example.com/full.webp',
        'receipt_thumb_url': 'https://example.com/thumb.webp',
        'participants': const <Map<String, dynamic>>[],
      });
      expect(expense.receiptUrl, 'https://example.com/full.webp');
      expect(expense.receiptThumbUrl, 'https://example.com/thumb.webp');
    });
  });

  group('WorkspaceRemoteParsers.parseUser', () {
    test('parses optional avatar thumbnail url', () {
      final user = WorkspaceRemoteParsers.parseUser(<String, dynamic>{
        'id': 7,
        'nickname': 'Matiss',
        'display_name': 'Matiss G',
        'avatar_url': 'https://example.com/avatar.webp',
        'avatar_thumb_url': 'https://example.com/avatar_thumb.webp',
      });
      expect(user.avatarUrl, 'https://example.com/avatar.webp');
      expect(user.avatarThumbUrl, 'https://example.com/avatar_thumb.webp');
    });
  });
}
