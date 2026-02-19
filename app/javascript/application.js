// Unpoly is loaded as a global script (IIFE) before this module runs.
// Configure Unpoly global behavior:

// Never cache new/edit form pages — always fetch fresh so forms open in clean state
up.network.config.autoCache = (request) => !request.url.match(/\/(new|edit)(\?|$)/)

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

// Optimistic delete preview: fade out the activity row immediately
up.preview('delete-activity', function(preview) {
  var row = preview.origin.closest('.activity-item')
  if (row) preview.setStyle(row, { opacity: '0.3', pointerEvents: 'none' })
})

// Activities filter — kind tabs (outside #activities-list, wired to the search form)
// Clicking a tab updates the hidden :kind field in #activities-filter-form and submits.
up.compiler('#activities-kind-tabs', function(element) {
  var tabs = element.querySelectorAll('[data-kind-tab]')

  tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
      var kind = tab.dataset.kindTab
      var hiddenField = document.getElementById('activities-kind-hidden')
      var form = document.getElementById('activities-filter-form')
      if (hiddenField) hiddenField.value = kind
      // Update active styling immediately (optimistic)
      tabs.forEach(function(t) {
        var active = t === tab
        t.classList.toggle('bg-white', active)
        t.classList.toggle('shadow-sm', active)
        t.classList.toggle('text-accent', active)
        t.classList.toggle('text-gray-500', !active)
        t.classList.toggle('hover:text-gray-700', !active)
      })
      if (form) up.submit(form)
    })
  })
})

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
