// Unpoly is loaded as a global script (IIFE) before this module runs.
// Configure Unpoly global behavior:

// Follow all links and forms by default
up.link.config.followSelectors.push('a[href]')
up.link.config.preloadSelectors.unshift('a[href]')
up.link.config.instantSelectors.unshift('a[href]')
up.form.config.submitSelectors.push('form')

// Optimistic star toggle preview
up.preview('toggle-star', function(preview) {
  let indicator = preview.fragment
  let wasStarred = indicator.classList.contains('starred')
  preview.addClass(indicator, wasStarred ? 'unstarred' : 'starred')
  preview.removeClass(indicator, wasStarred ? 'starred' : 'unstarred')
})

// Optimistic archive: fade out the contact row immediately
up.preview('archive-contact', function(preview) {
  let row = preview.origin.closest('.contact-row')
  if (row) preview.setStyle(row, { opacity: '0.3', pointerEvents: 'none' })
})

// Keep the search form's hidden filter field in sync with the current filter.
// Runs every time #contacts-list is swapped (search or filter tab click).
up.compiler('#contacts-list', function(element) {
  let filterInput = document.getElementById('search-filter')
  if (filterInput) filterInput.value = element.dataset.filter || ''
})

// Overlay style toggle (modal vs drawer)
function getOverlayStyle() {
  return localStorage.getItem('overlayStyle') || 'modal'
}

up.macro('[data-overlay-link]', function(link) {
  var style = getOverlayStyle()
  link.setAttribute('up-layer', 'new ' + style)
  if (style === 'drawer') {
    link.setAttribute('up-size', 'grow')
    link.setAttribute('up-position', 'right')
  }
})

window.toggleOverlayStyle = function() {
  const current = getOverlayStyle()
  const next = current === 'modal' ? 'drawer' : 'modal'
  localStorage.setItem('overlayStyle', next)
  document.querySelectorAll('[data-overlay-link]').forEach(function(el) {
    el.setAttribute('up-layer', 'new ' + next)
    if (next === 'drawer') {
      el.setAttribute('up-size', 'grow')
      el.setAttribute('up-position', 'right')
    } else {
      el.removeAttribute('up-size')
      el.removeAttribute('up-position')
    }
  })
}

// Helper: reload contacts list while preserving its scroll position
window.reloadContactsListPreservingScroll = function() {
  var list = document.getElementById('contacts-list');
  var scrollTop = list ? list.scrollTop : 0;
  up.reload('#contacts-list').then(function() {
    var newList = document.getElementById('contacts-list');
    if (newList) newList.scrollTop = scrollTop;
  });
};

// Flash toast auto-dismiss: fade out after 4 seconds
up.compiler('.flash-toast', function(element) {
  var timer = setTimeout(function() {
    element.classList.add('removing');
    setTimeout(function() { element.remove(); }, 300);
  }, 4000);
  return function() { clearTimeout(timer); };
});

// Activity kind segmented control
up.compiler('#activity-kind-selector', function(selector) {
  var form = selector.closest('form');
  var hiddenInput = form ? form.querySelector('input[name="activity[kind]"]') : null;
  var buttons = selector.querySelectorAll('.kind-btn');

  function selectKind(kind) {
    if (hiddenInput) hiddenInput.value = kind;
    buttons.forEach(function(btn) {
      var active = btn.dataset.kind === kind;
      btn.classList.toggle('bg-white', active);
      btn.classList.toggle('shadow-sm', active);
      btn.classList.toggle('text-accent', active);
      btn.classList.toggle('text-gray-500', !active);
      btn.classList.toggle('hover:text-gray-700', !active);
    });
  }

  selectKind(hiddenInput ? (hiddenInput.value || 'note') : 'note');

  buttons.forEach(function(btn) {
    btn.addEventListener('click', function() { selectKind(btn.dataset.kind); });
  });
});
