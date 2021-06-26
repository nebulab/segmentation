module Segmentation
  class Storage
    def read(user)
      raise NotImplementedError
    end

    def write(user, fields)
      raise NotImplementedError
    end
  end
end
