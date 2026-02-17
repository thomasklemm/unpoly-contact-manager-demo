# Unpoly Contact Manager — Demo App Specification

A Ruby on Rails application that demonstrates Unpoly's core features through a realistic, production-grade contact management interface.

---

## Overview

A single-page-feel contact manager where the **contacts list is always visible on the left**, and everything — viewing, editing, creating, deleting, filtering — happens without a full page reload. The server renders all HTML. No JSON APIs, no client-side routing frameworks.

**Stack:**
- Rails 8, SQLite
- Unpoly 3.x (CDN or gem)
- Tailwind CSS (for styling)
- No React, no Stimulus (except optionally for drag-and-drop; Unpoly compilers handle all JS)

---

## Data Model

### `Contact`

| column | type | notes |
|--------|------|-------|
| `id` | integer | |
| `first_name` | string | required |
| `last_name` | string | required |
| `email` | string | required, unique |
| `phone` | string | |
| `company_id` | integer | FK |
| `tag_ids` | array via join | many-to-many |
| `starred` | boolean | default false |
| `archived_at` | datetime | null = active |
| `notes` | text | |
| `created_at` | datetime | |

### `Company`

| column | type |
|--------|------|
| `id` | integer |
| `name` | string |
| `website` | string |

### `Tag`

| column | type |
|--------|------|
| `id` | integer |
| `name` | string |
| `color` | string | hex |

### `Activity`

| column | type | notes |
|--------|------|-------|
| `id` | integer | |
| `contact_id` | integer | |
| `kind` | string | `"note"`, `"call"`, `"email"` |
| `body` | text | |
| `created_at` | datetime | |

---

## Routes

```
GET    /contacts                → contacts#index
GET    /contacts/new            → contacts#new       (opens in overlay)
POST   /contacts                → contacts#create
GET    /contacts/:id            → contacts#show       (opens in drawer)
GET    /contacts/:id/edit       → contacts#edit       (opens in modal from drawer)
PATCH  /contacts/:id            → contacts#update
DELETE /contacts/:id            → contacts#destroy
PATCH  /contacts/:id/star       → contacts#star
PATCH  /contacts/:id/archive    → contacts#archive

GET    /companies               → companies#index     (used in subinteraction)
GET    /companies/new           → companies#new
POST   /companies               → companies#create

GET    /contacts/:id/activities → activities#index    (lazy-loaded panel)
POST   /contacts/:id/activities → activities#create
```

---

## Page Layout

```
┌─────────────────────────────────────────────────────────┐
│  TOPBAR  [Contacts]  [★ Starred]  [🗃 Archived]  search │
├──────────────────┬──────────────────────────────────────┤
│                  │                                       │
│  CONTACTS LIST   │    CONTACT DETAIL PANEL              │
│  (scrollable)    │    (appears on first click)          │
│                  │                                       │
│  [ + New ]       │                                       │
│  ─────────       │    (empty state: "Select a contact")  │
│  Alice Baker     │                                       │
│  Bob Carter      │                                       │
│  Carol Davis     │                                       │
│  ...             │                                       │
│                  │                                       │
└──────────────────┴──────────────────────────────────────┘
```

The layout has two fragments:
- `#contacts-list` — left column
- `#contact-detail` — right column

---

## Feature-by-Feature Breakdown

### 1. Fragment Updates — Contacts List & Detail Panel

**What it demonstrates:** `up-target`, `up-follow`, partial page replacement, URL updates, back button.

The contacts list is a `<ul id="contacts-list">`. Each contact row is a link:

```html
<a href="/contacts/42"
   up-target="#contact-detail"
   up-alias="/contacts/*"
   class="contact-row">
  Alice Baker
</a>
```

Clicking a contact fetches `/contacts/42` and replaces only `#contact-detail` with the matching element from the response. The URL updates to `/contacts/42`. The back button restores the previous detail panel.

The `#contacts-list` link also adds `.up-current` to the active row automatically via `[up-alias]`, highlighting who is selected.

**In the server:** `contacts#show` always renders the full layout (for direct URL access) but Unpoly only extracts `#contact-detail`. No special controller logic needed.

---

### 2. Preloading — Hover to Preload

**What it demonstrates:** `up-preload`, `up-instant`, perceived speed.

Add to each contact row link:

```html
<a href="/contacts/42"
   up-target="#contact-detail"
   up-preload
   up-instant>
```

`up-preload` fetches the contact detail on hover (before click). `up-instant` follows the link on mousedown instead of mouseup. Together they make navigation feel instantaneous.

---

### 3. Live Search / Filter — Fragment Targeting with Forms

**What it demonstrates:** `up-submit`, `up-autosubmit`, `up-target`, `up-delay`, no full page reload on search.

The search bar is a GET form:

```html
<form action="/contacts"
      up-submit
      up-target="#contacts-list"
      up-autosubmit
      up-delay="300">
  <input type="search" name="q" placeholder="Search contacts…">
</form>
```

`up-autosubmit` submits when the field changes. `up-delay="300"` debounces by 300ms. Only `#contacts-list` is updated — the detail panel stays untouched.

Add filter tabs (All / Starred / Archived) as links targeting the same fragment:

```html
<a href="/contacts?filter=starred" up-target="#contacts-list">★ Starred</a>
```

---

### 4. New Contact — Overlay (Modal)

**What it demonstrates:** `up-layer="new modal"`, overlay close conditions, `up-accept-location`, updating the list after close.

```html
<a href="/contacts/new"
   up-layer="new modal"
   up-accept-location="/contacts/:id"
   up-on-accepted="up.reload('#contacts-list')">
  + New Contact
</a>
```

- Opens a **modal** with the new contact form
- When the contact is created and redirects to `/contacts/:id`, the overlay auto-accepts
- `up-on-accepted` reloads `#contacts-list` in the root layer
- The modal dismisses cleanly; the new contact appears in the list

---

### 5. Contact Detail — Drawer Overlay

**What it demonstrates:** `up-layer="new drawer"`, drawer mode, layer isolation.

Clicking a contact row on mobile (or via a dedicated "Open" button on desktop) opens the contact as a **drawer** sliding in from the right:

```html
<a href="/contacts/42"
   up-layer="new drawer"
   up-size="medium">
  Open
</a>
```

The drawer is isolated — links inside it only affect the drawer by default. A "Back" button uses `up-dismiss` to close it.

---

### 6. Edit Contact — Modal from Drawer (Layered Subinteraction)

**What it demonstrates:** Stacked layers, returning a value from a nested overlay, updating the parent layer.

Inside the contact detail drawer, the Edit button opens a **modal on top of the drawer**:

```html
<a href="/contacts/42/edit"
   up-layer="new modal"
   up-accept-location="/contacts/42"
   up-on-accepted="up.reload('.contact-detail-content')">
  Edit
</a>
```

The edit form submits, redirects to `/contacts/42`, the modal auto-accepts, and `up-on-accepted` refreshes the detail content inside the drawer — without closing the drawer.

This shows **3 layers simultaneously**: root (list) → drawer (detail) → modal (edit form).

---

### 7. Form Validation — Server-Side, Inline Errors

**What it demonstrates:** `up-submit` with failed responses (422), `up-validate` for per-field validation.

The contact form uses standard Rails validations. The controller renders 422 on failure:

```ruby
def create
  @contact = Contact.new(contact_params)
  if @contact.save
    redirect_to @contact
  else
    render :new, status: :unprocessable_entity
  end
end
```

The form uses `up-validate` on email to validate as the user types (debounced server round-trip):

```html
<form action="/contacts" up-submit>
  <fieldset>
    <label>Email</label>
    <input type="email" name="contact[email]" up-validate>
    <!-- server renders error here on 422 -->
  </fieldset>

  <fieldset>
    <label>First name</label>
    <input name="contact[first_name]" up-validate>
  </fieldset>

  <button up-disable>Save Contact</button>
</form>
```

`up-disable` disables the submit button while the request is in flight, preventing double-submit.

---

### 8. Reactive Server Forms — Dependent Fields

**What it demonstrates:** `up-watch`, `up-validate`, server-controlled dynamic forms.

The contact form has a **Company** select. When a company is selected, the server returns an updated form section with company-specific options (e.g., a Department dropdown populated from that company's structure):

```html
<select name="contact[company_id]"
        up-watch
        up-target="#company-fields"
        up-watch-delay="0">
  <option value="">No company</option>
  <option value="1">Acme Corp</option>
</select>

<div id="company-fields">
  <!-- Rendered by server based on selected company -->
  <!-- e.g. a Department dropdown populated from that company's depts -->
</div>
```

When the select changes, Unpoly submits the form (without saving) and replaces `#company-fields` with the server-rendered dependent fields. No custom JavaScript needed.

---

### 9. Subinteraction — Create Company in a Nested Overlay

**What it demonstrates:** Nested overlay value passing, `up-accept-location`, `up-on-accepted` DOM manipulation.

While filling the New Contact form, if the company doesn't exist yet, a "Create company" link opens a nested modal:

```html
<a href="/companies/new"
   up-layer="new modal"
   up-accept-location="/companies/:id"
   up-on-accepted="
     let opt = document.createElement('option');
     opt.value = value.id;
     opt.text = value.name;
     opt.selected = true;
     document.querySelector('[name=contact\\[company_id\\]]').add(opt);
   ">
  + Create new company
</a>
```

The user creates the company in the nested modal. On success, `up-on-accepted` adds the new company as an `<option>` in the parent contact form's select and selects it. The contact form is never abandoned.

This shows Unpoly's "branch off and return" subinteraction pattern cleanly.

---

### 10. Lazy Loading — Activity Timeline

**What it demonstrates:** `up-defer`, skeleton placeholder, deferred content loading.

The contact detail panel has an Activity section. Its content is lazy-loaded after the main detail renders (so the detail panel appears instantly):

```html
<div id="contact-activities"
     up-defer="/contacts/42/activities"
     up-hungry>
  <!-- Placeholder shown while loading -->
  <div class="skeleton">
    <div class="skeleton-line"></div>
    <div class="skeleton-line skeleton-line--short"></div>
    <div class="skeleton-line"></div>
  </div>
</div>
```

`up-defer` triggers a separate request when the element enters the viewport. `up-hungry` makes the element automatically update if other requests render it fresh (e.g., after adding a new activity).

---

### 11. Optimistic Rendering — Star / Archive Contact

**What it demonstrates:** `up-preview`, immediate feedback without waiting for the server.

**Starring a contact** is optimistic — the star icon flips instantly:

```html
<button form="star-form"
        up-preview="toggle-star"
        up-target=".star-indicator">
  ★
</button>
<form id="star-form"
      action="/contacts/42/star"
      method="post"
      up-submit>
</form>
```

```js
up.preview('toggle-star', function(preview) {
  let indicator = preview.fragment
  let wasStarred = indicator.classList.contains('starred')
  preview.addClassTemporarily(indicator, wasStarred ? 'unstarred' : 'starred')
  preview.removeClassTemporarily(indicator, wasStarred ? 'starred' : 'unstarred')
})
```

**Archiving a contact** is also optimistic — the row fades out immediately from the list:

```js
up.preview('archive-contact', function(preview) {
  let row = preview.origin.closest('.contact-row')
  preview.setStyleTemporarily(row, { opacity: '0.3', pointerEvents: 'none' })
})
```

```html
<button up-preview="archive-contact"
        up-target="#contacts-list"
        up-confirm="Archive this contact?">
  Archive
</button>
```

---

### 12. Flash Messages

**What it demonstrates:** `[up-hungry]`, flash toasts appearing across layer changes.

A flash container in the layout uses `[up-hungry]`:

```html
<div id="flash" up-hungry aria-live="polite">
  <!-- Rails flash messages rendered here -->
  <!-- Appears automatically after any Unpoly navigation if present in response -->
</div>
```

Because `[up-hungry]` makes the element always update when present in a response, flash messages from form submissions inside overlays appear in the root layer correctly. No special handling needed.

---

### 13. Loading State — Global Progress Bar & CSS Classes

**What it demonstrates:** Built-in progress bar, `.up-loading`, `.up-active` CSS hooks.

Add the progress bar element to the layout:

```html
<up-progress-bar></up-progress-bar>
```

Style loading fragments with CSS:

```css
/* Dim the contact list while filtering */
#contacts-list.up-loading {
  opacity: 0.6;
  transition: opacity 0.15s;
}

/* Highlight the active link in the nav */
a.up-active {
  font-weight: bold;
}

/* Show spinner on submit buttons while loading */
button[type=submit].up-active::after {
  content: ' ⟳';
}
```

No JavaScript needed — these classes are added and removed by Unpoly automatically.

---

### 14. Delete Contact — Confirmation + Fragment Removal

**What it demonstrates:** `up-confirm`, cross-layer fragment updates.

```html
<a href="/contacts/42"
   up-method="delete"
   up-confirm="Delete Alice Baker? This cannot be undone."
   up-target="#contacts-list"
   up-layer="root">
  Delete
</a>
```

After deletion the controller redirects to `/contacts`. `up-target="#contacts-list"` updates the list in the root layer, and `up-layer="root"` ensures this happens even when triggered from inside the drawer overlay, then closes the drawer via `up-dismiss`.

---

### 15. Caching & Revalidation

**What it demonstrates:** Unpoly's automatic cache, `X-Up-Expire-Cache` response header.

Unpoly caches GET requests automatically. Contacts already visited load instantly from cache on revisit.

After creating or editing a contact, expire the contacts cache so the list refreshes on next visit:

```ruby
# In ContactsController
after_action :expire_contacts_cache, only: [:create, :update, :destroy]

def expire_contacts_cache
  response.headers['X-Up-Expire-Cache'] = '/contacts*'
end
```

This signals Unpoly to consider cached responses for `/contacts*` stale and refetch them on next access.

---

## Unpoly Features Demonstrated — Summary

| Feature | Where |
|---------|-------|
| `up-target` fragment updates | Contacts list, detail panel |
| `up-follow` / `up-instant` / `up-preload` | Contact row links |
| `up-layer="new modal"` | New Contact, Edit Contact |
| `up-layer="new drawer"` | Contact detail (mobile/CTA) |
| Subinteractions (`up-accept-location`) | Edit → closes modal, refreshes drawer |
| Nested overlays (3 layers) | List → Drawer → Edit Modal |
| `up-accept` value passing | Create Company → populates parent form select |
| `up-submit` | All forms |
| `up-validate` | Email uniqueness, name presence |
| `up-watch` + reactive fields | Company → Department dependent select |
| `up-disable` | Submit buttons during request |
| `up-defer` + skeleton placeholder | Activity timeline |
| `[up-hungry]` | Flash messages, activity panel |
| `up-preview` (optimistic rendering) | Star toggle, archive fade |
| `up-confirm` | Delete, Archive |
| `.up-loading`, `.up-active` CSS | List dim, button spinner |
| `<up-progress-bar>` | Global navigation bar |
| `X-Up-Expire-Cache` header | Post-mutation cache invalidation |
| `up-alias` + `.up-current` | Active contact row highlight |

---

## Rails-Specific Notes for the Coding Agent

- Use `respond_to` only where needed — Unpoly sends regular HTML requests; the controller is standard Rails.
- Render 422 (`status: :unprocessable_entity`) for failed form submissions so Unpoly knows to render the failure target.
- Use `X-Up-Expire-Cache` response header after mutations to invalidate the contacts list cache.
- The `flash` partial should always be rendered in the layout inside `#flash[up-hungry]` — not inside any fragment, so it persists across layer changes.
- Seed with ~30 realistic contacts (Faker gem) across 5 companies with varied tags so filtering and search are meaningful.
- Keep JavaScript minimal: all behavior above is pure HTML attributes. The only JS needed is the two `up.preview()` definitions for star and archive.
