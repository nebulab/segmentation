module Segmentation
  class Context
    attr_reader :request, :anonymous_id, :user

    def initialize(request: nil, anonymous_id: nil, user: nil)
      if anonymous_id.blank? && user_id.blank?
        raise Error, "You must supply either user_id or anonymous_id!"
      end

      @request = request
      @anonymous_id = anonymous_id
      @user = user
    end

    def user_id
      @user_id ||= Segmentation.config.user_id_builder.call(user)
    end

    def user_traits
      @user_traits ||= Segmentation.config.user_traits_builder.call(user)
    end

    def storage
      @storage ||= Segmentation.config.storage_builder.call(user)
    end

    def store_fields
      storage.write(user, storable_fields)
    end

    def context_from_destinations
      Segmentation.config.destinations.map do |destination|
        destination.context_from_fields(storable_fields)
      end.reduce({}, :merge).with_indifferent_access
    end

    def properties_from_destinations
      Segmentation.config.destinations.map do |destination|
        destination.properties_from_fields(storable_fields)
      end.reduce({}, :merge).with_indifferent_access
    end

    private

    def current_fields
      Segmentation.config.destinations.map do |destination|
        destination.fields_from_request(request)
      end.reduce({}, :merge).with_indifferent_access
    end

    def stored_fields
      storage.read(user).with_indifferent_access
    end

    def storable_fields
      stored_fields.merge(current_fields).with_indifferent_access
    end
  end
end
