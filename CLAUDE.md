# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Unpoly Reference (load on demand, not upfront)

Load skills only when the task involves Unpoly-specific work (views, overlays, forms, compilers, caching). Skip for pure Ruby/Rails tasks.

- **`/unpoly`** — Fragments, overlays, forms, caching, lazy loading, compilers, animations, lifecycle events.
- **`/unpoly-rails`** — `up?`, `up.target?`, `up.validate?`, `up.layer.*`, `up.cache.expire`, flash helpers, `form_with` gotchas.

**Prefer Context7 for targeted API lookups** (faster, no full skill load):
```
mcp__context7__query-docs(libraryId: "/unpoly/unpoly", query: "<your question>")
```
Context7 has 921 code snippets — use it for exact option names, event names, argument signatures.

**DeepWiki** for conceptual/architecture questions:
```
mcp__deepwiki__ask_question(repoName: "unpoly/unpoly", question: "<your question>")
```

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

## App-Specific Unpoly Patterns

These are patterns specific to this app's architecture. For general Unpoly API details, load the skills above.

**`up-defer` placeholder ID must match the server response wrapper ID** — the `#activities-panel` div in the placeholder and in `activities/index.html.erb` must be identical.

**Dual-purpose views use `up.layer.overlay?` to branch layout** — views that serve as both overlay fragments and full-page layouts check `up.layer.overlay?` (not `up?`) to decide which layout to render:
```erb
<% if up.layer.overlay? %>
  <div class="p-6 min-w-[32rem]" up-main><!-- overlay fragment --></div>
<% else %>
  <%= render 'sidebar' %>
  <div id="contact-detail" up-main><!-- full two-panel layout --></div>
<% end %>
```

**Non-overlay wrappers need `id="contact-detail"`** — the CSS rule `#contact-detail { background: #faf9f7; flex: 1 }` only applies when the wrapper carries this ID. All full-page layout wrappers (new, edit, show, companies pages) must use `<div id="contact-detail" up-main>`.

**Centralise sidebar data in ApplicationController** — a single `before_action :load_sidebar_contacts` loads `@contacts` for all non-overlay HTML requests. Controllers with their own `@contacts` query use `skip_before_action :load_sidebar_contacts`.

**Avoid shadowing `@contacts`** — when a controller action needs its own contacts collection (e.g., a company's contacts), name it `@company_contacts` so it doesn't overwrite the sidebar's `@contacts`.

**Use full partial paths when rendering across controller namespaces** — Rails resolves relative partial names to the current controller's namespace. Always use full paths to be safe:
```erb
<%= render 'contacts/contacts_list', contacts: @contacts %>
<%= render 'contacts/contact_row', contact: contact %>
```

**Rails 8 `form_with` silently drops top-level custom attributes** — only `:id, :class, :multipart, :method, :data, :authenticity_token` are passed to the `<form>` tag. All Unpoly attributes passed as top-level kwargs are silently dropped. Always use `html:`:
```erb
# WRONG — silently dropped
<%= form_with url: path, "up-target" => "#list", "up-validate" => "" do |f| %>
# CORRECT
<%= form_with url: path, html: { "up-target" => "#list", "up-validate" => "" } do |f| %>
```
`f.search_field`, `f.select`, etc. pass custom attributes fine — only the `form_with` call itself is affected.

**`up-on-accepted` is required to refresh fragments after overlay creation** — a link that opens an overlay must declare what to do when the overlay is accepted, otherwise the underlying page stays stale:
```erb
<%= link_to new_company_path,
      "data-overlay-link" => "",
      "up-on-accepted" => "up.reload('#contact-detail')" do %>New Company<% end %>
```
