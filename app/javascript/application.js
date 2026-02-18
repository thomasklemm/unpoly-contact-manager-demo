// Unpoly is loaded as a global script (IIFE) before this module runs.
// Configure Unpoly global behavior:

// Follow all links and forms by default
up.link.config.followSelectors.push('a[href]')
up.link.config.preloadSelectors.push('a[href]')
up.link.config.instantSelectors.push('a[href]')
up.form.config.submitSelectors.push('form')

// Optimistic star toggle preview
up.preview('toggle-star', function(preview) {
  let indicator = preview.fragment
  let wasStarred = indicator.classList.contains('starred')
  preview.addClassTemporarily(indicator, wasStarred ? 'unstarred' : 'starred')
  preview.removeClassTemporarily(indicator, wasStarred ? 'starred' : 'unstarred')
})

// Optimistic archive: fade out the contact row immediately
up.preview('archive-contact', function(preview) {
  let row = preview.origin.closest('.contact-row')
  if (row) preview.setStyleTemporarily(row, { opacity: '0.3', pointerEvents: 'none' })
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
  link.setAttribute('up-layer', 'new ' + getOverlayStyle())
})

window.toggleOverlayStyle = function() {
  const current = getOverlayStyle()
  const next = current === 'modal' ? 'drawer' : 'modal'
  localStorage.setItem('overlayStyle', next)
  // Re-compile all overlay links to pick up the new style
  document.querySelectorAll('[data-overlay-link]').forEach(function(el) {
    el.setAttribute('up-layer', 'new ' + next)
  })
  // Update toggle button appearance
  document.querySelectorAll('[data-overlay-toggle]').forEach(function(el) {
    el.setAttribute('data-current', next)
  })
}

// Initialize toggle button to match stored preference on compile
up.compiler('[data-overlay-toggle]', function(element) {
  element.setAttribute('data-current', getOverlayStyle())
})

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

// Highlight the active contact row in the sidebar list.
// Runs when #contacts-list is inserted/updated (search, filter, reload).
up.compiler('#contacts-list', function() {
  var url = up.layer.location;
  var match = url && url.match(/\/contacts\/(\d+)/);
  if (match) {
    var row = document.querySelector('.contact-row-' + match[1]);
    if (row) row.classList.add('selected');
  }
});

// When the contact detail panel updates, re-sync the selected row highlight.
up.compiler('#contact-detail', function() {
  document.querySelectorAll('.contact-row').forEach(function(row) {
    row.classList.remove('selected');
  });
  var url = up.layer.location;
  var match = url && url.match(/\/contacts\/(\d+)/);
  if (match) {
    var row = document.querySelector('.contact-row-' + match[1]);
    if (row) row.classList.add('selected');
  }
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
