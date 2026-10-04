// Type and erase roles without changing the accessible description.
(function () {
  'use strict';
  var target = document.getElementById('animated-role');
  if (!target) return;
  var preference = window.matchMedia('(prefers-reduced-motion: reduce)');
  var roles = [ { accent: 'Cloud', suffix: ' Engineer' }, { accent: 'DevOps', suffix: ' Engineer' } ];
  var roleIndex = 0, length = 14, erasing = true, timer;
  function render(role, count) {
    var accent = document.createElement('span');
    accent.className = 'role-accent';
    accent.textContent = role.accent.slice(0, count);
    target.replaceChildren(accent, document.createTextNode(role.suffix.slice(0, Math.max(0, count - role.accent.length))));
  }
  function step() {
    var role = roles[roleIndex], total = role.accent.length + role.suffix.length;
    length += erasing ? -1 : 1;
    render(role, length);
    if (erasing && length === 0) {
      roleIndex = (roleIndex + 1) % roles.length;
      erasing = false;
      timer = setTimeout(step, 300);
    } else if (!erasing && length === total) {
      erasing = true;
      timer = setTimeout(step, 2200);
    } else {
      timer = setTimeout(step, erasing ? 55 : 95);
    }
  }
  function start() {
    clearTimeout(timer);
    if (preference.matches) {
      target.replaceChildren();
      roles.forEach(function (role, index) {
        if (index) target.append(document.createTextNode(' / '));
        var accent = document.createElement('span');
        accent.className = 'role-accent'; accent.textContent = role.accent;
        target.append(accent, document.createTextNode(role.suffix));
      });
      return;
    }
    roleIndex = 0; length = 14; erasing = true;
    render(roles[0], length);
    timer = setTimeout(step, 2200);
  }
  preference.addEventListener('change', start);
  start();
})();
