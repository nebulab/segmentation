require "segmentation/testing/backend"

RSpec.describe Segmentation::Testing::Backend do
  describe '#identify' do
    it 'saves the payload' do
      backend = described_class.new
      payload = { traits: { first_name: 'John', last_name: 'Doe' } }

      backend.identify(payload)

      expect(backend.identifies).to eq([payload])
    end
  end

  describe '#track' do
    it 'saves the payload' do
      backend = described_class.new
      payload = { event: 'Order Completed' }

      backend.identify(payload)

      expect(backend.identifies).to eq([payload])
    end
  end
end
