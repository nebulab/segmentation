class ApplicationController < ActionController::Base
  include Segmentation::ControllerHelpers

  # The name of the cookie where you'll store the events
  # to be tracked on the next page load via JS.
  def segmentation_js_events_cookie
    "sjsevts"
  end

  # The name of the cookie where you'll store the
  # anonymous ID generated for the user.
  def segmentation_anonymous_id_cookie
    "sanmid"
  end

  # The user object to pass to use for building
  # user IDs, traits and the storage.
  def current_user_for_segmentation
    User.first_or_create!(first_name: "John", last_name: "Doe")
  end
end
