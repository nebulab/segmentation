module Segmentation
  class Client
    attr_reader :context

    def initialize(context)
      @context = context
    end

    def identify(traits = {}, options = {})
      payload = {
        user_id: context.user_id,
        anonymous_id: context.anonymous_id,
        traits: context.user_traits.merge(traits),
        context: context.context_from_destinations.merge(traits: context.user_traits.merge(traits)),
        **options
      }

      Segmentation.config.backend.identify(payload)
    end

    def track(event, properties = {}, options = {})
      payload = {
        user_id: context.user_id,
        anonymous_id: context.anonymous_id,
        event: event,
        properties: context.properties_from_destinations.merge(properties),
        context: context.context_from_destinations.merge(traits: context.user_traits),
        **options
      }

      Segmentation.config.backend.track(payload)
    end
  end
end
