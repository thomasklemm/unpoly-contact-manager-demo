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
