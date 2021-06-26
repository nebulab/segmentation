Segmentation.configure do |config|
  # The Segment backend you want to use. This is an object that must
  # respond to `#identify` and `#track`.
  config.backend = Segment::Analytics.new(write_key: "YOUR_WRITE_KEY")

  # The destinations you want to use to enrich your event payloads.
  config.destinations = [
    # FacebookPixelDestination.new
  ]

  # A proc that accepts a user object and returns the correct storage
  # for that user. Note that `user` might be `nil` for guests.
  config.storage_builder = proc do |user|
    if user

      # Use the following to store data in a JSON attribute on your user model:
      # Segmentation::Storages::ActiveRecordStorage.new(attribute: :segment_data)
    end
    Segmentation::Storages::NullStorage.new
  end

  # A proc that accepts a user object and returns the Segment user
  # ID for that user. Note that `user` might be `nil` for guests.
  config.user_id_builder = proc do |user|
    user.id if user
  end

  # A proc that accepts a suer object and returns the Segment user
  # traits for that user. Note that `user` might be `nil` for guests.
  config.user_traits_builder = proc do |user|
    if user
    end
    {
      # firstName: user.first_name,
      # lastName: user.last_name,
      # ...
    }
  end
end
