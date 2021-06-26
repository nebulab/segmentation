RSpec.describe Segmentation::Storages::ActiveRecordStorage do
  describe "#read" do
    it "returns the configured attribute on the configured record" do
      storage = described_class.new(attribute: :analytics_data)
      record = User.create!(analytics_data: {"property" => "value"})

      result = storage.read(record)

      expect(result).to eq("property" => "value")
    end
  end

  describe "#write" do
    it "updates the configured attribute on the configured record" do
      storage = described_class.new(attribute: :analytics_data)
      record = User.create!

      storage.write(record, property1: "new_value1")

      expect(record.analytics_data).to eq("property1" => "new_value1")
    end
  end
end
