class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # DEMO_MODE: slow down responses so Unpoly progress bar and transitions are visible
  before_action :demo_delay, if: -> { ENV["DEMO_MODE"].present? }

  # Sidebar contacts — loaded for every non-overlay HTML request so the
  # contacts sidebar is available whenever the full two-panel layout is rendered.
  # Individual actions that manage their own @contacts query use skip_before_action.
  before_action :load_sidebar_contacts

  private

  def demo_delay
    sleep(0.3)
  end

  def load_sidebar_contacts
    return if up.layer.overlay?

    @contacts = Contact.active
                       .includes(:company, :tags)
                       .order(Arel.sql("LOWER(contacts.last_name), LOWER(contacts.first_name)"))
  end
end
