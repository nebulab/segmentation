module Segmentation
  module Storages
    class ActiveRecordStorage < Storage
      attr_reader :attribute

      def initialize(attribute:)
        super()

        @attribute = attribute
      end

      def read(user)
        (user.send(attribute) || {}).dup.with_indifferent_access
      end

      def write(user, fields)
        user.update(attribute => fields)
      end
    end
  end
end
