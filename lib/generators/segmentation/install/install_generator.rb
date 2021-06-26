module Segmentation
  class InstallGenerator < Rails::Generators::Base
    source_root File.expand_path("templates", __dir__)

    def copy_initializer_file
      copy_file "initializer.rb", "config/initializers/segmentation.rb"
    end

    def configure_base_controller
      inject_into_class "app/controllers/application_controller.rb", "ApplicationController" do
        <<~RUBY.split("\n").map { |r| "  #{r}" }.join("\n") + "\n"
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
            current_user
          end
        RUBY
      end
    end
  end
end
