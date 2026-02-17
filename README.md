# Unpoly Contact Manager

A production-grade demo app that shows what **server-rendered Rails looks like when it's fast**.
Built with [Unpoly 3](https://unpoly.com) — no React, no JSON API, no client-side routing.
The server renders all HTML. Unpoly handles the rest.

```
┌──────────────────────────────────────────────────────────┐
│  Contacts                                    + New Contact│
├───────────────────┬──────────────────────────────────────┤
│ 🔍 Search…        │  Ada Lovelace                    ★   │
│ All  Starred  Arc │  Acme Corp                           │
│───────────────────│  ✉️  ada@acme.com                     │
│ 👤 Ada Lovelace   │  📞  +1-555-0101                     │
│ 👤 Bob Williams   │                                      │
│ 👤 Carol Davis  ★ │  Tags: Customer  VIP                 │
│ 👤 David Martinez │                                      │
│ 👤 Eve Anderson ★ │  Activity ─────────────────────────  │
│ 👤 Frank Thomas   │  📝 Note  2 days ago                 │
│ 👤 Grace Jackson  │     Discussed enterprise pricing     │
│ 👤 Henry White  ★ │  📞 Call  1 week ago                 │
│                   │     Quarterly check-in               │
└───────────────────┴──────────────────────────────────────┘
```

---

## Why Unpoly?

Most SPAs solve a simple problem — faster page transitions — but bring enormous complexity:
a build pipeline, a client-side router, two rendering environments, JSON endpoints, and
state management on top of the database state you already have.

Unpoly takes a different path. You keep writing normal Rails views. Unpoly progressively
enhances them: fragment updates, overlays, instant navigation, form validation, optimistic UI,
lazy loading — all from HTML attributes. **No JavaScript framework. No API layer.**

---

## 15 Unpoly Features Demonstrated

| # | Feature | Where | Attribute / API |
|---|---------|-------|-----------------|
| 1 | **Fragment update** | Click a contact row | `up-target="#contact-detail"` |
| 2 | **Preload on hover** | Contact rows | `up-preload` |
| 3 | **Instant navigation** | Contact rows | `up-instant` |
| 4 | **URL alias** | Contact rows | `up-alias="/contacts/*"` |
| 5 | **Live search** | Search box | `up-autosubmit`, `up-delay="300"` |
| 6 | **New contact modal** | "+ New Contact" button | `up-layer="new modal"`, `up-accept-location` |
| 7 | **Edit modal** | Edit button in detail panel | `up-layer="new modal"`, `up-on-accepted` |
| 8 | **Per-field validation** | Contact form fields | `up-validate` |
| 9 | **Reactive select** | Company dropdown | `up-watch`, `up-target="#company-fields"` |
| 10 | **Create company subinteraction** | "+ New company" link in form | Nested `up-layer="new modal"`, `up-on-accepted` injects `<option>` |
| 11 | **Lazy loading** | Activity timeline | `up-defer` |
| 12 | **Optimistic star toggle** | Star button | `up-preview="toggle-star"` |
| 13 | **Optimistic archive** | Archive button | `up-preview="archive-contact"` |
| 14 | **Flash messages** | After mutations | `#flash[up-hungry]` |
| 15 | **Progress bar** | During navigation | `<up-progress-bar>` |

---

## Tech Stack

| | |
|--|--|
| **Backend** | Ruby on Rails 8.1, SQLite, Puma |
| **Frontend** | Unpoly 3 (importmap + jsDelivr CDN), Tailwind CSS (Play CDN) |
| **Gem** | [`unpoly-rails`](https://github.com/unpoly/unpoly-rails) for server-side helpers |
| **Seed data** | [`faker`](https://github.com/faker-ruby/faker) — 30 contacts, 5 companies, 8 tags |

No webpack. No Node.js build step. No JSON API. Everything is HTML, rendered on the server.

---

## Quick Start

```bash
git clone <repo>
cd unpoly-demo

bundle install
bin/rails db:create db:migrate db:seed
bin/rails server
```

Open [http://localhost:3000](http://localhost:3000).

---

## What to Try

1. **Click a contact** — right panel updates, URL changes, no full reload
2. **Hover a row** — it silently preloads (watch the Network tab)
3. **Type in search** — list updates after 300 ms, only the left panel refreshes
4. **Click "+ New Contact"** — modal appears; submit and it closes, list refreshes, flash appears
5. **Click "Edit"** — modal opens on top of the detail; save closes it cleanly
6. **Click ★** — icon toggles *immediately* (optimistic); server confirms
7. **Click "Archive"** — row fades out at once; server redirects to refreshed list
8. **Click "Delete"** — confirmation dialog; contact gone, no full reload
9. **Watch the Activity section** — it lazy-loads after the detail panel settles
10. **Change company in the form** — dependent fields re-render from the server

---

## Server-Side Helpers (`unpoly-rails`)

The `unpoly-rails` gem adds request-aware helpers to controllers and views:

```ruby
# Is this an Unpoly fragment request?
up?

# Respond only to validation requests (triggered by up-validate)
if up.validate?
  @contact.valid?
  render :new, status: :unprocessable_entity and return
end

# Accept a modal overlay (closes it on the client)
up.layer.accept(@company.id) if up.layer.overlay?
up.render_nothing

# Expire the client-side cache after mutations
up.cache.expire("/contacts*")
```

---

## Claude Code Agent Skills for Unpoly

This repo ships with two [Claude Code](https://claude.ai/code) agent skills that bring
Unpoly's full documentation into your AI coding sessions:

- **`unpoly`** — core Unpoly docs (fragments, overlays, forms, caching, previews, lifecycle)
- **`unpoly-rails`** — Rails integration docs (`up?`, `up.layer`, `up.validate?`, `up.cache`, etc.)

### Install the skills

```bash
# Install from the unpoly-skills repository
git clone https://github.com/thomasklemm/unpoly-skills /tmp/unpoly-skills

# Copy into your project's Claude skills directory
mkdir -p .claude/skills
cp -r /tmp/unpoly-skills/unpoly   .claude/skills/
cp -r /tmp/unpoly-skills/unpoly-rails .claude/skills/
```

Once installed, Claude Code will automatically use them when you work on Unpoly features.
You can also reference them explicitly:

```
/unpoly How does up-defer work?
/unpoly-rails How do I expire cache after a form submission?
```

---

## Project Structure

```
app/
  controllers/
    contacts_controller.rb   # index, show, new, create, edit, update, destroy, star, archive
    companies_controller.rb  # new, create (modal subinteraction)
    activities_controller.rb # index, create (lazy-loaded panel)
  models/
    contact.rb               # validations, scopes (active/starred/archived)
    company.rb
    tag.rb / contact_tag.rb
    activity.rb
  views/
    contacts/
      index.html.erb          # two-panel shell
      _contacts_list.html.erb # filter tabs + live search + rows
      _contact_row.html.erb   # up-target, up-preload, up-instant
      _contact_detail.html.erb # star, archive, delete, lazy activities
      _form.html.erb          # up-validate, reactive select, subinteraction
    companies/
      new.html.erb            # modal form
    activities/
      index.html.erb          # timeline + inline add form (lazy via up-defer)
  javascript/
    application.js            # Unpoly config + preview definitions
```

---

## Tests

```bash
# All tests (unit + integration + system)
bin/rails test:all

# System tests only (headless Chrome)
bin/rails test:system

# Unit + integration tests only
bin/rails test

# System tests in a visible browser window
HEADED=1 bin/rails test:system

# System tests with 300 ms server delay (shows Unpoly progress bar + transitions)
DEMO_MODE=1 bin/rails test:system
```

---

## License

MIT
