module Segmentation
  module Testing
    class Backend
      def identifies
        @identifies ||= []
      end

      def identify(payload)
        identifies << payload
      end

      def tracks
        @tracks ||= []
      end

      def track(payload)
        tracks << payload
      end
    end
  end
end
