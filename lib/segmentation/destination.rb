module Segmentation
  class Destination
    attr_reader :options

    def initialize(options = {})
      @options = options
    end

    def fields_from_request(request)
      raise NotImplementedError
    end

    def context_from_fields(fields)
      raise NotImplementedError
    end

    def properties_from_fields(fields)
      raise NotImplementedError
    end
  end
end
