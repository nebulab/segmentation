module Segmentation
  module ControllerHelpers
    extend ActiveSupport::Concern

    included do
      before_action :setup_segmentation
      helper_method :segmentation_js_tag
    end

    def segmentation
      @segmentation
    end

    def segmentation_server_track(event, properties, options = {})
      segmentation.track(event, properties, options)
    end

    def segmentation_client_track(event, properties, options = {})
      delegated_events = segmentation_js_events

      delegated_events << {
        event: event,
        properties: properties,
        options: options
      }

      cookies.permanent[segmentation_js_events_cookie] = Base64.encode64(JSON.dump(delegated_events))
    end

    def segmentation_js_tag
      loading_js = <<~JS
        analytics.setAnonymousId('#{helpers.escape_javascript(segmentation.context.anonymous_id)}');
        analytics.identify('#{helpers.escape_javascript(segmentation.context.user_id)}', #{JSON.dump(segmentation.context.user_traits)});
        analytics.page();
      JS

      deferred_tracking_js = segmentation_js_events.map do |event|
        <<~JS
          analytics.track(
            '#{helpers.escape_javascript(event[:event])}',
            #{JSON.dump(event[:properties])},
            #{JSON.dump(event[:options])}
          );
        JS
      end.join("\n")

      <<~HTML.html_safe
        <script>
          #{loading_js}
          #{deferred_tracking_js} 
        </script>
      HTML
    end

    private

    def segmentation_js_events_cookie
      "sjsevts"
    end

    def segmentation_anonymous_id_cookie
      "sanmid"
    end

    def current_user_for_segmentation
      current_user
    end

    def setup_segmentation
      cookies.permanent[segmentation_anonymous_id_cookie] ||= SecureRandom.uuid

      context = Segmentation::Context.new(
        request: request,
        anonymous_id: cookies[segmentation_anonymous_id_cookie],
        user: current_user_for_segmentation
      )

      @segmentation = Segmentation::Client.new(context)

      @segmentation.context.store_fields

      @segmentation.identify if current_user_for_segmentation
    end

    def segmentation_js_events
      return [] unless cookies[segmentation_js_events_cookie]

      events = begin
        JSON.parse(Base64.decode64(cookies[segmentation_js_events_cookie]))
      rescue JSON::ParserError
        []
      end

      events.is_a?(Array) ? events : []
    end
  end
end
