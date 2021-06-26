RSpec.describe Segmentation::Client do
  describe "#identify" do
    it "identifies the user in Segment" do
      backend = instance_spy(Segment::Analytics::Client)
      allow(Segmentation.config).to receive(:backend).and_return(backend)
      context = instance_double(
        Segmentation::Context,
        anonymous_id: "anonymous_id",
        user_id: "user_id",
        user_traits: {trait1: "value1"},
        context_from_destinations: {key1: "value1"}
      )

      described_class.new(context).identify(custom_trait: "custom_value")

      expect(backend).to have_received(:identify).with(
        user_id: "user_id",
        anonymous_id: "anonymous_id",
        traits: {
          trait1: "value1",
          custom_trait: "custom_value"
        },
        context: {
          key1: "value1",
          traits: {
            trait1: "value1",
            custom_trait: "custom_value"
          }
        }
      )
    end
  end

  describe "#track" do
    it "tracks an event in Segment" do
      backend = instance_spy(Segment::Analytics::Client)
      allow(Segmentation.config).to receive(:backend).and_return(backend)
      context = instance_double(
        Segmentation::Context,
        properties_from_destinations: {field1: "value1", sku: "OLDSKU"},
        context_from_destinations: {context1: "value1"},
        user_traits: {trait1: "value1"},
        user_id: "user_id",
        anonymous_id: "anonymous_id"
      )

      described_class.new(context).track("Product Viewed", {sku: "PP"})

      expect(backend).to have_received(:track).with(
        user_id: "user_id",
        anonymous_id: "anonymous_id",
        event: "Product Viewed",
        properties: {
          sku: "PP",
          field1: "value1"
        },
        context: {
          context1: "value1",
          traits: {
            trait1: "value1"
          }
        }
      )
    end
  end
end
