# require File.expand_path 'spec_helper.rb', __dir__
require 'ostruct'
require 'byebug'

RSpec.describe F1SalesCustom::Hooks::Lead do
  describe '#switch_source' do
    let(:lead) do
      lead = OpenStruct.new
      lead.source = source
      lead.product = product
      lead.customer = customer
      lead.message = 'message'
      lead.description = 'description'
      lead.id = lead_id

      lead
    end

    let(:source) do
      source = OpenStruct.new
      source.name = 'Other source'

      source
    end

    let(:product) do
      product = OpenStruct.new
      product.name = 'product name'

      product
    end

    let(:customer) do
      customer = OpenStruct.new
      customer.name = 'customer name'
      customer.email = 'customer email'
      customer.phone = 'customer phone'

      customer
    end

    let(:switch_source) { described_class.switch_source(lead) }

    context 'when lead is from Facebook' do
      let(:call_url) { 'https://toribaveiculos.f1sales.org/public/api/v1/leads' }
      let(:lead_class_double) { class_double('Lead').as_stubbed_const }
      let(:count_lead) { 0 }
      let(:lead_id) { '123leadid' }
      let(:lead_created_payload) do
        {
          'data' => {
            'id' => 'newleadabc123'
          }
        }
      end

      before do
        source.name = 'Facebook - Toriba Veículos Volkswagen'
        stub_request(:post, call_url).with(body: lead_payload.to_json).to_return(status: 200, body: lead_created_payload.to_json, headers: {})
        allow(lead_class_double).to receive(:where).with(source: source)
                                                   .and_return(double('relation', count: count_lead))
      end

      let(:lead_payload) do
        {
          lead: {
            message: lead.message,
            description: lead.description,
            customer: {
              name: customer.name,
              email: customer.email,
              phone: customer.phone
            },
            product: {
              name: product.name
            },
            transferred_path: {
              from: 'toribapompeia',
              id: lead_id
            },
            source: {
              name: 'Facebook - Toriba Veículos Volkswagen'
            }
          }
        }
      end

      context 'when count lead is even' do
        it 'returns Source Name - Focal source' do
          expect(switch_source).to eq("#{source.name} - Veículos")
        end

        it 'marks the lead as contacted' do
          begin
            switch_source
          rescue StandardError
            nil
          end

          expect(lead.interaction).to eq(:contacted)
        end

        it 'post to simmons dream comfort' do
          begin
            switch_source
          rescue StandardError
            nil
          end

          expect(WebMock).to have_requested(:post, call_url).with(body: lead_payload)
        end
      end

      context 'When count lead is odd' do
        let(:count_lead) { 1 }

        it 'returns Source Name - L opes source' do
          expect(switch_source).to eq(source.name)
        end
      end
    end

    context 'When lead is not from Facebook' do
      it 'returns Source Name' do
        expect(switch_source).to eq(source.name)
      end
    end
  end
end
