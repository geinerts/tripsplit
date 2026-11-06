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
