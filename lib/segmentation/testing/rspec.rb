module Segmentation
  module Testing
    module RSpec
      extend ::RSpec::Matchers::DSL

      matcher :have_identified do |expected_payload|
        match do |segmentation|
          unless segmentation.config.backend.respond_to?(:identifies)
            raise Error, <<~ERROR
              `Segmentation.backend` must respond to `#identifies` in order for `have_identified`
              to work. Try adding the following to your `rails_helper.rb`:
  
                require "segmentation/testing/backend"
                RSpec.configure do |config|
                  config.before do
                    Segmentation.config.backend = Segmentation::Testing::Backend.new
                  end
                end
            ERROR
          end

          segmentation.config.backend.identifies.any? do |actual_payload|
            values_match?(expected_payload, actual_payload)
          end
        end
      end

      matcher :have_tracked do |expected_payload|
        match do |segmentation|
          unless segmentation.config.backend.respond_to?(:tracks)
            raise Error, <<~ERROR
              `Segmentation.backend` must respond to `#tracks` in order for `have_tracked`
              to work. Try adding the following to your `rails_helper.rb`:
  
                require "segmentation/testing/backend"
                RSpec.configure do |config|
                  config.before do
                    Segmentation.config.backend = Segmentation::Testing::Backend.new
                  end
                end
            ERROR
          end

          segmentation.config.backend.tracks.any? do |actual_payload|
            values_match?(expected_payload, actual_payload)
          end
        end
      end
    end
  end
end
