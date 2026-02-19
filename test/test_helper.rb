ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers (single process in demo mode)
    parallelize(workers: ENV["DEMO_MODE"] ? 1 : :number_of_processors)

    # In demo mode, run tests in definition order so a human watching can follow along.
    i_suck_and_my_tests_are_order_dependent! if ENV["DEMO_MODE"]

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
  end
end
