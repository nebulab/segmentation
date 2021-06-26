RSpec.describe Segmentation::Context do
  describe "#store_fields" do
    it "updates the fields through the storage" do
      storage = stub_storage(property1: "old_value1", property2: "old_value2")
      destination = stub_destination(fields_from_request: {
        property1: "new_value1",
        property3: "new_value3"
      })
      allow(Segmentation.config).to receive_messages(
        storage_builder: ->(_) { storage },
        destinations: [destination]
      )
      user = double("User")

      build_context(user: user).store_fields

      expect(storage).to have_received(:write).with(
        user,
        {
          "property1" => "new_value1",
          "property2" => "old_value2",
          "property3" => "new_value3"
        }
      )
    end
  end

  describe "#properties_from_destinations" do
    it "returns the properties of all destinations" do
      destination1 = stub_destination(properties_from_fields: {property1: "value1"})
      destination2 = stub_destination(properties_from_fields: {property2: "value2"})
      allow(Segmentation.config).to receive_messages(
        storage_builder: ->(_) { stub_storage },
        destinations: [destination1, destination2]
      )

      context = build_context

      expect(context.properties_from_destinations).to eq(
        "property1" => "value1",
        "property2" => "value2"
      )
    end
  end

  describe "#context_from_destinations" do
    it "returns the context of all destinations" do
      destination1 = stub_destination(context_from_fields: {key1: "value1"})
      destination2 = stub_destination(context_from_fields: {key2: "value2"})
      allow(Segmentation.config).to receive_messages(
        storage_builder: ->(_) { stub_storage },
        destinations: [destination1, destination2]
      )

      context = build_context

      expect(context.context_from_destinations).to eq(
        "key1" => "value1",
        "key2" => "value2"
      )
    end
  end

  private

  def stub_destination(fields_from_request: {}, context_from_fields: {}, properties_from_fields: {})
    instance_double(
      "Segmentation::Destination",
      fields_from_request: fields_from_request,
      context_from_fields: context_from_fields,
      properties_from_fields: properties_from_fields
    )
  end

  def stub_storage(fields = {})
    instance_spy("Segmentation::Storage", read: fields.with_indifferent_access, write: true)
  end

  def build_context(options = {})
    if options[:user_id].blank? && options[:anonymous_id].blank?
      options[:anonymous_id] = SecureRandom.uuid
    end

    described_class.new(**options)
  end
end
