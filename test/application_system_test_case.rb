require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["HEADED"] || ENV["DEMO_MODE"]
    driven_by :selenium, using: :chrome, screen_size: [ 1400, 900 ]
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]
  end
end
