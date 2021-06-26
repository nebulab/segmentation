module Segmentation
  module Storages
    class NullStorage < Storage
      def read(user)
        {}.with_indifferent_access
      end

      def write(user, _fields)
        true
      end
    end
  end
end
