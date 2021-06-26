require "segmentation/version"
require "segmentation/engine"
require "segmentation/client"
require "segmentation/controller_helpers"
require "segmentation/configuration"
require "segmentation/destination"
require "segmentation/storage"
require "segmentation/storages/active_record_storage"
require "segmentation/storages/null_storage"
require "segmentation/context"

module Segmentation
  def self.config
    @config ||= Configuration.new
  end

  def self.configure
    yield config
  end
end
