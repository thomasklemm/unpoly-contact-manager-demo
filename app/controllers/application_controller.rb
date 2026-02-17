class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  # DEMO_MODE: slow down responses so Unpoly progress bar and transitions are visible
  before_action :demo_delay, if: -> { ENV["DEMO_MODE"].present? }

  private

  def demo_delay
    sleep(0.3)
  end
end
