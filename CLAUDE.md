# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Setup
bundle install
bin/rails db:create db:migrate db:seed

# Run server
bin/rails server

# All tests (unit + integration + system)
bin/rails test:all

# A single test file
bin/rails test test/system/contacts_test.rb

# System tests only (headless Chrome)
bin/rails test:system

# System tests in a visible browser (for debugging)
HEADED=1 bin/rails test:system

# System tests with artificial server delay (shows progress bar)
DEMO_MODE=1 bin/rails test:system

# Linting
bundle exec rubocop
bundle exec brakeman
```

## Architecture

Rails 8.1 + SQLite + Unpoly 3. No webpack, no Node, no JSON API. All rendering is server-side HTML. Unpoly is loaded from jsDelivr CDN as a blocking IIFE before importmap modules. Tailwind is loaded from the Play CDN — no build step.

### Fragment IDs that drive everything

The UI is a two-panel shell with two key fragment targets:
- `#contacts-sidebar` — the left panel (never replaced during navigation; wraps search form + `#contacts-list`)
- `#contacts-list` — replaced on search/filter changes
- `#contact-detail` — replaced when clicking a contact row

The search form lives **outside** `#contacts-list` so it survives fragment swaps and retains focus.

### JavaScript (`app/javascript/application.js`)

Global Unpoly configuration and all client-side behavior live here. Key patterns:
- `up.link.config` / `up.form.config` — opt all links and forms into Unpoly globally
- `up.preview('toggle-star', ...)` / `up.preview('archive-contact', ...)` — optimistic UI definitions
- `up.compiler('#contacts-list', ...)` — keeps the hidden filter field in sync with `data-filter`; highlights the active row after list swaps
- `up.compiler('#contact-detail', ...)` — re-syncs selected row highlight when detail panel changes
- `up.macro('[data-overlay-link]', ...)` — resolves to `up-layer="new modal"` or `up-layer="new drawer"` at runtime from `localStorage`

### Controllers

**`ApplicationController`** — has a `before_action :load_sidebar_contacts` that loads `@contacts` for every non-overlay HTML request. This keeps sidebar data centralised rather than scattered across every action. Actions that manage their own `@contacts` query (index, show, star, archive, destroy in ContactsController; index, show in CompaniesController) use `skip_before_action :load_sidebar_contacts`.

**`ContactsController`** — the main controller. Handles validation-only requests (`up.validate?`) and Unpoly target checks (`up? && up.target?("#company-fields")`) before saving. On success in an overlay, calls `up.layer.accept(contact_path(@contact))` + `head :no_content` instead of redirecting.

**`CompaniesController`** — full CRUD. `new`/`create` can be opened as an overlay (sub-interaction from the contact form) or navigated to directly. Accepts the overlay with `{ id:, name: }` so the parent contact form's select can update. Uses `@company_contacts` (not `@contacts`) in `show` to avoid shadowing the sidebar's `@contacts`.

**`ActivitiesController`** — lazy-loaded via `up-defer`. The `index` action renders the timeline; `create` adds a new activity inline.

### Cache expiry

`ContactsController` has an `after_action :expire_contacts_cache` that calls `up.cache.expire("/contacts*")` after all mutations (create, update, destroy, star, archive).

### Flash messages

Flash is rendered in `app/views/shared/_flash.html.erb` with `#flash[up-hungry]` so it updates across fragment swaps without a full page reload.

### Views structure

```
contacts/index.html.erb          — two-panel shell (sidebar + empty detail panel)
contacts/show.html.erb           — two-panel shell with contact detail loaded
contacts/new.html.erb            — overlay? → modal fragment; else → sidebar + form in #contact-detail
contacts/edit.html.erb           — overlay? → modal fragment; else → sidebar + form in #contact-detail
contacts/_sidebar.html.erb       — extracted sidebar partial; accepts q: and filter: locals
contacts/_contacts_list.html.erb — filter tabs + contact rows fragment (uses full paths: contacts/contact_row)
contacts/_contact_row.html.erb   — up-target, up-preload, up-instant, up-alias
contacts/_contact_detail.html.erb — star, archive, delete, up-defer activities panel
contacts/_form.html.erb          — up-validate on form, reactive company select (up-watch)
companies/index.html.erb         — sidebar + companies list in #contact-detail; up-on-accepted reloads list
companies/show.html.erb          — overlay? → modal fragment; else → sidebar + company detail
companies/new.html.erb           — overlay? → modal fragment; else → sidebar + form in #contact-detail
activities/index.html.erb        — wraps content in `#activities-panel` (must match up-defer id)
```

### Models

- `Contact` — `belongs_to :company` (optional), `has_many :tags` through `ContactTag`, `has_many :activities`; scopes: `active`, `starred`, `archived`
- `Company`, `Tag`, `ContactTag`, `Activity` — supporting models

## Critical Unpoly Gotchas

These are documented in `~/.claude/projects/.../memory/MEMORY.md` but are so important they bear repeating:

**`up.target?` is always true for non-Unpoly requests** — always guard with `up?` first:
```ruby
if up.validate? || (up? && up.target?("#company-fields"))
```

**`form_with` in Rails 8 silently drops top-level Unpoly attributes** — always use the `html:` option:
```erb
<%= form_with url: path, html: { "up-validate" => "", "up-target" => "#list" } do |f| %>
```

**`up-defer` placeholder ID must match the server response wrapper ID** — the `#activities-panel` div in the placeholder and in `activities/index.html.erb` must be identical.

**Modal views need `up-main`** — add to the outer wrapper div of any view opened as a modal/drawer layer, otherwise Unpoly throws `up.CannotMatch: Could not find common target`.

**`up.render_nothing` is deprecated** — use `head(:no_content)` instead.

**`up-accept-location` must not match the opening URL** — use the controller pattern (`up.layer.accept` + `head :no_content`) instead.

**`up.layer.overlay?` is the correct conditional for dual-purpose views** — views that serve as both overlay fragments and full-page layouts should use `up.layer.overlay?`, not `up?`. `up?` is true for any Unpoly request including base-layer navigation; `up.layer.overlay?` is only true for modal/drawer layers:
```erb
<% if up.layer.overlay? %>
  <div class="p-6 min-w-[32rem]" up-main><!-- overlay fragment --></div>
<% else %>
  <%= render 'sidebar' %>
  <div id="contact-detail" up-main><!-- full two-panel layout --></div>
<% end %>
```

**Centralise sidebar data in ApplicationController** — rather than loading `@contacts` in every action that renders a full-page layout, use a single `before_action`:
```ruby
# application_controller.rb
before_action :load_sidebar_contacts

def load_sidebar_contacts
  return if up.layer.overlay?
  @contacts = Contact.active.includes(:company, :tags).order(...)
end
```
Controllers with their own `@contacts` query skip it: `skip_before_action :load_sidebar_contacts, only: [...]`

**Avoid shadowing `@contacts` in controllers that render the sidebar** — when a controller action needs its own contacts collection (e.g., a company's contacts), name it differently (`@company_contacts`) so it doesn't overwrite the sidebar's `@contacts` set by `load_sidebar_contacts`.

**Use full partial paths when rendering across controller namespaces** — when a partial is called from a different controller's view context, Rails resolves relative partial names to that controller's namespace. Always use full paths to be safe:
```erb
<%# In contacts/_sidebar.html.erb (can be called from companies/) %>
<%= render 'contacts/contacts_list', contacts: @contacts %>

<%# In contacts/_contacts_list.html.erb %>
<%= render 'contacts/contact_row', contact: contact %>
```

**`up-on-accepted` is required to refresh fragments after overlay creation** — a link that opens an overlay must declare what to do when the overlay is accepted, otherwise the underlying page stays stale:
```erb
<%= link_to new_company_path,
      "data-overlay-link" => "",
      "up-on-accepted" => "up.reload('#contact-detail')" do %>New Company<% end %>
```

**`up-dismiss` only works inside an overlay** — wrapping Cancel buttons in `up.layer.overlay?` prevents rendering a broken/no-op button on full-page layouts:
```erb
<% if up.layer.overlay? %>
  <button type="button" up-dismiss="">Cancel</button>
<% end %>
```

**Non-overlay wrappers need `id="contact-detail"`** — the CSS rule `#contact-detail { background: #faf9f7; flex: 1 }` only applies when the wrapper carries this ID. All full-page layout wrappers (new, edit, show, companies pages) must use `<div id="contact-detail" up-main>`.
