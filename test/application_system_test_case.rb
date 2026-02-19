require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["HEADED"] || ENV["DEMO_MODE"]
    driven_by :selenium, using: :chrome, screen_size: [ 1400, 900 ]
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 900 ]
  end

  # ── Unpoly network helpers ──────────────────────────────────────────────────

  # Wait until Unpoly has no requests in flight.
  #
  # This is essential before interacting with forms that use up-validate:
  # clicking a new field blurs the previous one, which fires up-validate.
  # The server re-renders the form. If you type into the new field while
  # that re-render is in progress, your typed value may be lost.
  #
  # Call wait_for_unpoly_idle after the blur-triggering click and before
  # typing into the next field.
  def wait_for_unpoly_idle(timeout: 5)
    sleep 0.05 # give Unpoly a tick to queue the request
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    loop do
      busy = page.evaluate_script("typeof up !== 'undefined' && up.network.isBusy()")
      break unless busy
      elapsed = Process.clock_gettime(Process::CLOCK_MONOTONIC) - start
      raise Capybara::ExpectationNotMet, "Timed out waiting for Unpoly network to be idle (#{timeout}s)" if elapsed > timeout
      sleep 0.05
    end
  end

  # Fill a form field in a form that uses up-validate.
  #
  # The pattern:
  #   1. Click the target field  → blurs the previous field → up-validate fires
  #   2. settle_form (blur active + wait for idle) → drains any in-flight validates,
  #      including one the newly focused field itself may trigger on blur
  #   3. Re-find the field in the refreshed DOM and set the value
  #
  # Using settle_form (not just wait_for_unpoly_idle) ensures the newly focused
  # field's own up-validate is also drained before we type, not just the previous
  # field's validation.
  def fill_form_field(label, value)
    find_field(label).click   # focus + trigger blur-validate on previous field
    settle_form               # blur active element + wait for all validates to drain
    find_field(label).set(value) # fill the now-stable field
  end

  # After filling all form fields, call this before clicking submit.
  #
  # Without it there is a race: clicking the submit button blurs the last
  # field which fires up-validate concurrently with the form submission.
  # If the validate response arrives after the flash is set, it re-renders
  # the form with an *empty* #flash[up-hungry], wiping out the success toast.
  #
  # Pre-blurring via JS drains that validate request before submission.
  def settle_form
    page.execute_script("document.activeElement.blur()")
    wait_for_unpoly_idle
  end

  # ── Demo helpers ────────────────────────────────────────────────────────────

  # Sleep briefly in DEMO_MODE so a human watching can follow along.
  def demo_pause(seconds = 1.2)
    sleep seconds if ENV["DEMO_MODE"]
  end

  # ── Overlay convenience helpers ─────────────────────────────────────────────

  def within_modal(&block)
    within("up-modal-box", &block)
  end

  def within_drawer(&block)
    within("up-drawer-box", &block)
  end
end
