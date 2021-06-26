RSpec.describe Segmentation::Storages::NullStorage do
  describe "#read" do
    it "returns an empty hash" do
      storage = described_class.new

      expect(storage.read(nil)).to eq({})
    end
  end

  describe "#write" do
    it "returns true" do
      storage = described_class.new

      expect(storage.write(nil, {})).to eq(true)
    end
  end
end
