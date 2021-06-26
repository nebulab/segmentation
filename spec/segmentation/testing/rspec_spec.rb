require "segmentation/testing/backend"
require "segmentation/testing/rspec"

RSpec.describe Segmentation::Testing::RSpec do
  include described_class

  describe '#have_identified' do
    it 'passes when the provided identify call has been executed' do
      backend = Segmentation::Testing::Backend.new
      allow(Segmentation.config).to receive(:backend).and_return(backend)

      backend.identify(traits: { first_name: 'John', last_name: 'Doe' })

      expect(Segmentation).to have_identified(traits: a_hash_including({ first_name: 'John' }))
    end

    it 'fails when the provided identify call has not been executed' do
      backend = Segmentation::Testing::Backend.new
      allow(Segmentation.config).to receive(:backend).and_return(backend)

      backend.identify(traits: { first_name: 'Jane', last_name: 'Doe' })

      expect(Segmentation).not_to have_identified(traits: a_hash_including({ first_name: 'John' }))
    end
  end

  describe '#have_tracked' do
    it 'passes when the provided track call has been executed' do
      backend = Segmentation::Testing::Backend.new
      allow(Segmentation.config).to receive(:backend).and_return(backend)

      backend.track(event: 'Order Completed', properties: { order_id: 1, total: 59.0 })

      expect(Segmentation).to have_tracked(
        event: 'Order Completed',
        properties: a_hash_including(total: 59.0),
      )
    end

    it 'fails when the provided track call has not been executed' do
      backend = Segmentation::Testing::Backend.new
      allow(Segmentation.config).to receive(:backend).and_return(backend)

      backend.track(event: 'Order Completed', properties: { order_id: 1, total: 59.0 })

      expect(Segmentation).not_to have_tracked(
        event: 'Order Completed',
        properties: a_hash_including(total: 61.0),
      )
    end
  end
end
