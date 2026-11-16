// Home page story: one phone that changes while scrolling, live map, settle-up animation, counters.
(function () {
  'use strict';

  var reduceMotion = window.matchMedia('(prefers-reduced-motion: reduce)').matches;

  /* ---------- Story: one phone from the hero to the live map ---------- */
  (function () {
    var story = document.querySelector('.story');
    if (!story || !('IntersectionObserver' in window)) return;
    var rail = story.querySelector('.story__rail');
    var stage = story.querySelector('.story__stage');
    var dotBox = story.querySelector('.story__dots');
    var dots = [];
    var heroPhone = story.querySelector('.hero__phone .phone');
    var heroCopy = story.querySelector('.hero__copy');
    var sections = [story.querySelector('.hero')].concat(
      Array.prototype.slice.call(story.querySelectorAll('.feature'))
    );
    var tallEnough = window.matchMedia('(min-height: 560px)');
    var shots = [];
    var ribbons = [];
    var floats = [];
    var active = -1;
    var built = false;

    function sourcePhone(sec) {
      return sec.querySelector('.hero__phone .phone, .feature__stage .phone');
    }

    function liveFx() {
      var fx = document.createElement('div');
      fx.className = 'live-fx';
      fx.innerHTML = '<div class="live-fx__map">' +
        ['alex', 'sofia', 'marta'].map(function (p) {
          return '<span class="live-fx__person live-fx__person--' + p + '">' +
            '<img src="/site/images/people/' + p + '.webp" width="70" height="70" alt=""></span>';
        }).join('') + '</div>';
      return fx;
    }

    // One phone frame; only the screens inside it change, plus each section's floating cards.
    function build() {
      if (built) return;
      built = true;
      var phone = document.createElement('div');
      phone.className = 'phone story__phone';
      phone.innerHTML = '<div class="phone__bezel"><div class="phone__screen"></div></div>';
      var screen = phone.querySelector('.phone__screen');
      sections.forEach(function (sec) {
        var src = sourcePhone(sec);
        var shot = document.createElement('div');
        shot.className = 'story__shot is-below no-anim';
        var img = src.querySelector('.screen-shot').cloneNode(true);
        img.loading = 'eager';
        shot.appendChild(img);
        if (/live-map/.test(img.getAttribute('src'))) shot.appendChild(liveFx());
        screen.appendChild(shot);
        shots.push(shot);
        var group = document.createElement('div');
        group.className = 'story__floats';
        src.querySelectorAll(':scope > .float').forEach(function (f) { group.appendChild(f.cloneNode(true)); });
        phone.appendChild(group);
        floats.push(group);
      });
      stage.appendChild(phone);

      // Dots: one per step. Tap one, or slide along them and let go, to jump to a step.
      dotBox.innerHTML = '';
      sections.forEach(function (sec, k) {
        var b = document.createElement('button');
        b.type = 'button';
        b.className = 'story__dot';
        b.tabIndex = -1;
        var h = sec.querySelector('h1, h2');
        b.setAttribute('aria-label', h ? h.textContent.trim() : 'Step ' + (k + 1));
        dotBox.appendChild(b);
        dots.push(b);
      });
      bindDots();

      // One ribbon layer that stays put; each section's ribbons fade in over the last.
      var bg = story.querySelector('.story__bg');
      sections.forEach(function (sec) {
        var src = sec.querySelector(':scope > .ribbons, .feature__stage .ribbons');
        var img = document.createElement('img');
        img.className = 'story__ribbon';
        img.alt = '';
        img.src = src.getAttribute('src');
        bg.appendChild(img);
        ribbons.push(img);
      });
    }

    /* Phones: the phone stays fully visible and short text changes above it. */
    var mobile = window.matchMedia('(max-width: 900px)');
    var sticky = story.querySelector('.story__sticky');
    var textPanel = null;
    var copies = [];
    var viz = story.querySelector('.settle-viz');
    var vizHome = viz ? viz.parentNode : null;
    var vizNext = viz ? viz.nextSibling : null;
    var vizSection = viz ? viz.closest('.feature') : null;
    var fit = { start: 0, offset: 0, snapEnd: Infinity };
    var root = document.documentElement;
    var stableVh = 0;
    var lastW = 0;
    var queued = false;

    function buildText() {
      if (textPanel) return;
      textPanel = document.createElement('div');
      textPanel.className = 'story__text';
      sections.forEach(function (sec) {
        var copy = document.createElement('div');
        copy.className = 'story__copy is-right no-anim';
        var src = sec.querySelector('.feature__copy');
        if (src) {
          var c = src.cloneNode(true);
          // Phones get the heading and the first sentence; the full text stays on desktop.
          c.querySelectorAll('.settle-viz, .ticks').forEach(function (v) { v.remove(); });
          var lead = c.querySelector('.lead');
          if (lead) {
            var first = lead.textContent.trim().match(/^.*?[.!?](?=\s|$)/);
            if (first) lead.textContent = first[0];
          }
          c.classList.remove('will-reveal', 'is-in');
          while (c.firstChild) copy.appendChild(c.firstChild);
        }
        textPanel.appendChild(copy);
        copies.push(copy);
      });
      sticky.appendChild(textPanel);
    }

    // On phones the settle-up chart floats over the phone's side in the settle step.
    var vizFloat = null;
    function placeViz(onPhone) {
      if (!viz) return;
      if (onPhone) {
        if (!vizFloat) {
          vizFloat = document.createElement('div');
          vizFloat.className = 'story__viz';
          sticky.appendChild(vizFloat);
          floats[sections.indexOf(vizSection)].classList.add('has-viz');
        }
        vizFloat.appendChild(viz);
      } else {
        vizHome.insertBefore(viz, vizNext);
      }
      viz.classList.toggle('settle-viz--mini', onPhone);
    }

    // Start the shared phone exactly where the hero phone sits, then let it stick.
    function measure() {
      var sr = story.getBoundingClientRect();
      var pr = heroPhone.getBoundingClientRect();
      var header = 68;
      var vh = stableVh || window.innerHeight;
      var startY = pr.top - sr.top;
      var storyTop = sr.top + window.scrollY;

      if (mobile.matches) {
        var avail = vh - header;
        // Room the tallest short text needs above the phone.
        textPanel.style.zoom = 1;
        var tallest = 0;
        copies.forEach(function (c) { tallest = Math.max(tallest, c.scrollHeight); });
        var textNeed = 18 + tallest + 14;
        // The whole phone stays visible; it only gets smaller on very short screens.
        var scale = Math.min(1, Math.max(0.62, (avail - textNeed - 16) / pr.height));
        var phoneH = pr.height * scale;
        var phoneTop = Math.min(avail - 16 - phoneH, storyTop + startY - header);
        rail.style.setProperty('--phone-scale', scale.toFixed(3));
        rail.style.setProperty('--phone-top', phoneTop + 'px');
        story.style.setProperty('--phone-top', phoneTop + 'px');
        // Scroll up with the page from the hero, then stay put.
        rail.style.setProperty('--start-y', (startY - phoneTop) + 'px');
        var stickyH = Math.max(avail, phoneTop + phoneH + 8);
        rail.style.setProperty('--sticky-h', stickyH + 'px');
        rail.style.setProperty('--viz-top', (phoneTop + phoneH * 0.42) + 'px');
        // The text lives between the header and the phone; shrink it only if it still does not fit.
        var textH = phoneTop - 32;
        var zoom = Math.min(1, Math.max(0.7, textH / tallest));
        textPanel.style.zoom = zoom.toFixed(3);
        rail.style.setProperty('--text-h', (textH / zoom) + 'px');
        // The first feature takes over as soon as the hero text has scrolled away.
        var copyBottom = heroCopy.getBoundingClientRect().bottom + window.scrollY;
        fit.start = copyBottom - header - 20;
        fit.offset = (sections[1].getBoundingClientRect().top + window.scrollY) - fit.start;
        rail.style.setProperty('--phone-h', phoneH + 'px');
        // Snap points: one swipe moves one step, however fast the swipe is.
        story.style.setProperty('--snap-offset', (fit.offset - 4) + 'px');
        // The last step is only as tall as the pinned phone needs, so the page moves on
        // right after it instead of scrolling through empty space.
        var last = sections[sections.length - 1];
        var lastSnap = last.getBoundingClientRect().top + window.scrollY - (fit.offset - 4);
        var railEnd = rail.getBoundingClientRect().bottom + window.scrollY;
        var extra = railEnd - (lastSnap + header + stickyH);
        last.style.height = Math.max(1, Math.round(last.offsetHeight - extra)) + 'px';
        // Snapping stops at the last step; below it the page scrolls freely, and coming
        // back up it only catches the last step once you reach it.
        fit.snapEnd = lastSnap + 6;
        onScroll();
        return;
      }

      sections[sections.length - 1].style.height = '';
      var stick = Math.max(header + 16, (vh + header - pr.height) / 2);
      // Never stick lower than where the phone starts, so nothing jumps on load.
      stick = Math.min(stick, storyTop + startY);
      rail.style.setProperty('--start-y', startY + 'px');
      rail.style.setProperty('--start-x', (pr.left - sr.left) + 'px');
      rail.style.setProperty('--stick-top', stick + 'px');
      // Ribbons: a band around the phone, about as big as in the original sections.
      var ribW = Math.min(pr.width * 2.5, 760);
      var ribH = pr.height + 90;
      story.style.setProperty('--rib-w', ribW + 'px');
      story.style.setProperty('--rib-h', ribH + 'px');
      story.style.setProperty('--rib-left', (pr.left + pr.width / 2 - ribW / 2) + 'px');
      story.style.setProperty('--rib-top', (stick - header - 45) + 'px');
    }

    function onScroll() {
      queued = false;
      if (!mobile.matches || !story.classList.contains('story--on')) {
        root.classList.remove('story-snap');
        return;
      }
      var y = window.scrollY;
      root.classList.toggle('story-snap', y < fit.snapEnd - 2);
      var t = Math.max(0, Math.min(1, (y - fit.start + 40) / 80));
      textPanel.style.opacity = t.toFixed(3);
      // On phones the dots appear together with the story text.
      dotBox.style.opacity = t.toFixed(3);

      // Step through the sections a little earlier than their tops, in step with the text.
      var idx = 0;
      for (var k = 1; k < sections.length; k++) {
        if (y >= sections[k].getBoundingClientRect().top + y - fit.offset) idx = k;
      }
      if (jumpTarget < 0) activate(idx);
    }

    /* Desktop: while scrolling fast the phone holds its screen; when scrolling stops it
       goes straight to the step you stopped at. Slow scrolling changes screens as usual. */
    var FAST = 1.2; // px per ms
    var speed = 0;
    var lastY = window.scrollY;
    var lastT = 0;
    var idleTimer = 0;

    function trackSpeed() {
      var now = performance.now();
      var y = window.scrollY;
      var dt = lastT ? Math.max(1, now - lastT) : 16;
      speed = speed * 0.6 + (Math.abs(y - lastY) / dt) * 0.4;
      lastY = y;
      lastT = now;
      if (mobile.matches || jumpTarget >= 0) return;
      clearTimeout(idleTimer);
      idleTimer = setTimeout(function () {
        speed = 0;
        lastT = 0;
        if (jumpTarget < 0 && story.classList.contains('story--on')) activate(currentIndex());
      }, 140);
    }

    window.addEventListener('scroll', function () {
      trackSpeed();
      if (jumpTarget >= 0) settleJumpLater(180);
      if (queued) return;
      queued = true;
      requestAnimationFrame(onScroll);
    }, { passive: true });

    /* Jumping from a dot: show the chosen step at once and ignore the steps scrolled past. */
    var jumpTarget = -1;
    var jumpTimer = 0;

    function currentIndex() {
      return indexAt(window.scrollY);
    }

    // Which step is showing when the page is scrolled to y.
    function indexAt(y) {
      if (mobile.matches) {
        var idx = 0;
        for (var k = 1; k < sections.length; k++) {
          if (y >= sections[k].getBoundingClientRect().top + y - fit.offset) idx = k;
        }
        return idx;
      }
      var mid = y + window.innerHeight / 2;
      for (var i = sections.length - 1; i >= 0; i--) {
        if (sectionTop(i) <= mid) return i;
      }
      return 0;
    }

    // Links within the page (the logo, the menu) jump the same way as the dots.
    document.addEventListener('click', function (e) {
      if (!story.classList.contains('story--on')) return;
      var a = e.target.closest ? e.target.closest('a[href^="#"]') : null;
      if (!a) return;
      var id = a.getAttribute('href').slice(1);
      var el = id ? document.getElementById(id) : null;
      if (!el) return;
      var pad = parseFloat(getComputedStyle(root).scrollPaddingTop) || 0;
      var dest = Math.max(0, el.getBoundingClientRect().top + window.scrollY - pad);
      var k = indexAt(dest);
      jumpTarget = k;
      activate(k);
      settleJumpLater(1500);
    });

    // The jump is over once scrolling has been quiet for a moment.
    function settleJumpLater(ms) {
      clearTimeout(jumpTimer);
      jumpTimer = setTimeout(function () {
        jumpTarget = -1;
        activate(currentIndex());
      }, ms);
    }

    function sectionTop(k) {
      return sections[k].getBoundingClientRect().top + window.scrollY;
    }

    function goTo(k) {
      var header = 68;
      var top;
      if (k === 0) top = 0;
      else if (mobile.matches) top = sectionTop(k) - fit.offset + 4;
      else top = sectionTop(k) - header + 1;
      jumpTarget = k;
      activate(k);
      settleJumpLater(1500);
      window.scrollTo({ top: Math.max(0, top), behavior: reduceMotion ? 'auto' : 'smooth' });
    }

    // Which dot is closest to a pointer's height.
    function dotAt(y) {
      var best = 0;
      var bestDist = Infinity;
      dots.forEach(function (d, k) {
        var r = d.getBoundingClientRect();
        var dist = Math.abs(r.top + r.height / 2 - y);
        if (dist < bestDist) { bestDist = dist; best = k; }
      });
      return best;
    }

    function bindDots() {
      var dragging = false;
      var preview = -1;

      function show(k) {
        if (k === preview) return;
        preview = k;
        dots.forEach(function (d, i) { d.classList.toggle('is-preview', i === k); });
        // A light tick on each new dot while sliding (Android; iPhone browsers ignore it).
        if (dragging && navigator.vibrate) navigator.vibrate(4);
      }

      function hide() {
        preview = -1;
        dots.forEach(function (d) { d.classList.remove('is-preview'); });
        dotBox.classList.remove('is-dragging');
      }

      dotBox.addEventListener('pointerdown', function (e) {
        dragging = true;
        if (dotBox.setPointerCapture) dotBox.setPointerCapture(e.pointerId);
        dotBox.classList.add('is-dragging');
        show(dotAt(e.clientY));
        e.preventDefault();
      });
      dotBox.addEventListener('pointermove', function (e) {
        if (dragging || e.pointerType === 'mouse') show(dotAt(e.clientY));
      });
      dotBox.addEventListener('pointerup', function (e) {
        if (!dragging) return;
        dragging = false;
        var k = dotAt(e.clientY);
        hide();
        goTo(k);
      });
      dotBox.addEventListener('pointercancel', function () { dragging = false; hide(); });
      dotBox.addEventListener('pointerleave', function () { if (!dragging) hide(); });
    }

    function activate(i) {
      if (i === active) return;
      var prev = active;
      active = i;
      shots.forEach(function (s, k) {
        // Only the outgoing and incoming screens animate; the rest move unseen.
        s.classList.toggle('no-anim', prev < 0 || (k !== i && k !== prev));
        s.classList.toggle('is-active', k === i);
        s.classList.toggle('is-above', k < i);
        s.classList.toggle('is-below', k > i);
      });
      copies.forEach(function (c, k) {
        // Text comes in from the right going down, and from the left going back up.
        c.classList.toggle('no-anim', prev < 0 || (k !== i && k !== prev));
        c.classList.toggle('is-active', k === i);
        c.classList.toggle('is-left', k < i);
        c.classList.toggle('is-right', k > i);
      });
      floats.forEach(function (g, k) { g.classList.toggle('is-active', k === i); });
      ribbons.forEach(function (r, k) { r.classList.toggle('is-active', k === i); });
      if (vizFloat) vizFloat.classList.toggle('is-active', sections[i] === vizSection);
      if (viz && mobile.matches && sections[i] === vizSection) viz.dispatchEvent(new CustomEvent('settle:play'));
      dots.forEach(function (d, k) { d.classList.toggle('is-on', k === i); });
    }

    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting && !mobile.matches && jumpTarget < 0 && speed < FAST) activate(sections.indexOf(e.target));
      });
    }, { rootMargin: '-50% 0px -49% 0px' });

    function apply() {
      lastW = window.innerWidth;
      stableVh = window.innerHeight;
      if (tallEnough.matches) {
        build();
        buildText();
        story.classList.add('story--on');
        story.classList.toggle('story--mobile', mobile.matches);
        placeViz(mobile.matches);
        textPanel.style.opacity = '';
        dotBox.style.opacity = '';
        measure();
        // Measure again once layout and fonts have settled.
        requestAnimationFrame(measure);
        if (document.fonts && document.fonts.ready) document.fonts.ready.then(measure);
        if (active < 0) activate(0);
        sections.forEach(function (s) { io.observe(s); });
      } else {
        story.classList.remove('story--on', 'story--mobile');
        placeViz(false);
        io.disconnect();
      }
    }

    var resizeTimer;
    window.addEventListener('resize', function () {
      clearTimeout(resizeTimer);
      resizeTimer = setTimeout(function () {
        var w = window.innerWidth;
        // Phones change height when the address bar hides; that must not move the layout.
        if (w === lastW && mobile.matches) return;
        lastW = w;
        stableVh = window.innerHeight;
        if (story.classList.contains('story--on')) measure();
      }, 120);
    });
    window.addEventListener('load', function () { if (story.classList.contains('story--on')) measure(); });
    [tallEnough, mobile].forEach(function (mq) {
      if (mq.addEventListener) mq.addEventListener('change', apply); else mq.addListener(apply);
    });
    apply();
  })();

  /* ---------- Floating cards pop in (when the story is off) ---------- */
  (function () {
    if (reduceMotion || !('IntersectionObserver' in window)) return;
    document.documentElement.classList.add('js-floats');
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); }
      });
    }, { threshold: 0.35 });
    document.querySelectorAll('.feature__stage').forEach(function (s) { io.observe(s); });
  })();

  /* ---------- Settle-up animation ---------- */
  (function () {
    var viz = document.querySelector('.settle-viz');
    if (!viz) return;
    var num = viz.querySelector('.settle-viz__num');
    var timers = [];

    function run() {
      timers.forEach(clearTimeout);
      timers = [];
      if (reduceMotion) {
        viz.classList.add('is-messy', 'is-clean');
        num.textContent = '2';
        return;
      }
      viz.classList.remove('is-messy', 'is-clean');
      num.textContent = '6';
      void viz.offsetWidth;
      viz.classList.add('is-messy');
      timers.push(setTimeout(function () {
        viz.classList.add('is-clean');
        [5, 4, 3, 2].forEach(function (n, k) {
          timers.push(setTimeout(function () { num.textContent = String(n); }, k * 90));
        });
      }, 1700));
    }

    viz.querySelector('.settle-viz__replay').addEventListener('click', run);
    viz.addEventListener('settle:play', run);
    if ('IntersectionObserver' in window) {
      var io = new IntersectionObserver(function (entries) {
        if (entries[0].isIntersecting) { run(); io.disconnect(); }
      }, { threshold: 0.6 });
      io.observe(viz);
    } else {
      run();
    }
  })();

  /* ---------- Counting numbers ---------- */
  (function () {
    if (reduceMotion || !('IntersectionObserver' in window)) return;
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (!e.isIntersecting) return;
        io.unobserve(e.target);
        var el = e.target;
        var end = +el.dataset.count;
        var start = performance.now();
        var dur = 1100;
        (function tick(now) {
          var p = Math.min(1, (now - start) / dur);
          el.textContent = String(Math.round(end * (1 - Math.pow(1 - p, 3))));
          if (p < 1) requestAnimationFrame(tick);
        })(start);
      });
    }, { threshold: 0.6 });
    document.querySelectorAll('[data-count]').forEach(function (el) { io.observe(el); });
  })();

  /* ---------- Reveal on scroll ---------- */
  (function () {
    if (reduceMotion || !('IntersectionObserver' in window)) return;
    var targets = document.querySelectorAll(
      '.feature__copy, .feature__stage, ' +
      '.details .wrap > *, .steps .wrap > *, .privacy .wrap > *, .closing .wrap > *'
    );
    document.documentElement.classList.add('js-reveal');
    var io = new IntersectionObserver(function (entries) {
      entries.forEach(function (e) {
        if (e.isIntersecting) { e.target.classList.add('is-in'); io.unobserve(e.target); }
      });
    }, { rootMargin: '0px 0px -10% 0px', threshold: 0.12 });
    targets.forEach(function (el) {
      if (el.getBoundingClientRect().top < window.innerHeight) return;
      el.classList.add('will-reveal');
      io.observe(el);
    });
  })();
})();
