// The logo goes to the home page. On the home page itself it scrolls to the
// top without adding "#top" or another hash to the address.
(function () {
  'use strict';

  var logo = document.querySelector('.site-logo');
  if (!logo) return;
  logo.addEventListener('click', function (event) {
    if (event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
    if (window.location.pathname !== '/' && window.location.pathname !== '/index.html') return;
    event.preventDefault();
    window.scrollTo({ top: 0 });
    if (window.location.hash) {
      history.replaceState(null, '', window.location.pathname + window.location.search);
    }
  });
})();

// Ribbons drift slightly while scrolling, as they do in the app's Quick Start.
(function () {
  'use strict';

  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) return;

  var DRIFT = -0.06;
  var ribbons = document.querySelectorAll('.ribbons');
  var queued = false;

  function update() {
    queued = false;
    ribbons.forEach(function (ribbon) {
      var top = ribbon.parentElement.getBoundingClientRect().top;
      ribbon.style.transform = 'translate3d(0,' + (top * DRIFT).toFixed(1) + 'px,0)';
    });
  }

  window.addEventListener('scroll', function () {
    if (queued) return;
    queued = true;
    window.requestAnimationFrame(update);
  }, { passive: true });
})();
