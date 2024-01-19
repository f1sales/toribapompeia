require 'toribapompeia/version'
require 'f1sales_custom/parser'
require 'f1sales_custom/source'
require 'f1sales_custom/hooks'
require 'f1sales_helpers'

module Toribapompeia
  class Error < StandardError; end

  class F1SalesCustom::Email::Source
    def self.all
      [
        {
          email_id: 'website',
          name: 'Website - Novos'
        },
        {
          email_id: 'website',
          name: 'Website - Seminovos'
        }
      ]
    end
  end

  class F1SalesCustom::Email::Parser
    def parse
      parsed_email = @email.body.colons_to_hash
      all_sources = F1SalesCustom::Email::Source.all
      source = all_sources[0]
      source = all_sources[1] if @email.subject.downcase.include?('seminovos')

      {
        source: {
          name: source[:name]
        },
        customer: {
          name: parsed_email['nome'],
          phone: parsed_email['telefone'].tr('^0-9', ''),
          email: parsed_email['email']
        },
        product: (parsed_email['interesse'] || ''),
        message: (parsed_email['menssage'] || parsed_email['mensagem']).gsub('-', ' ').gsub("\n", ' ').strip,
        description: parsed_email['assunto']
      }
    end
  end

  class F1SalesCustom::Hooks::Lead
    class << self
      def switch_source(lead)
        @lead = lead
        @source_name = source.name
        distribute_facebook_leads if facebook?

        @source_name
      end

      private

      def facebook?
        @source_name.downcase['facebook']
      end

      def source
        @lead.source
      end

      def distribute_facebook_leads
        return if Lead.where(source: source).count.odd?

        @source_name = "#{@source_name} - Veículos"
        post_to_toribaveiculos
        @lead.interaction = :contacted
      end

      def post_to_toribaveiculos
        response = HTTP.post('https://toribaveiculos.f1sales.org/public/api/v1/leads', json: lead_payload)

        byebug
        JSON.parse(response.body)
      end

      def lead_payload
        {
          lead: {
            customer: customer_data,
            product: product_name,
            source: source_name,
            message: @lead.message,
            description: @lead.description,
            transferred_path: transferred_path
          }
        }
      end

      def customer_data
        {
          name: customer.name,
          email: customer.email,
          phone: customer.phone
        }
      end

      def customer
        @lead.customer
      end

      def product_name
        {
          name: @lead.product.name
        }
      end

      def source_name
        {
          name: 'Facebook - Toriba Veículos Volkswagen'
        }
      end

      def transferred_path
        {
          from: 'toribapompeia',
          id: @lead.id.to_s
        }
      end
    end
  end
end


'{"lead":{"customer":{"name":"customer name","email":"customer email","phone":"customer phone"},"product":{"name":"product name"},"source":{"name":"Facebook - Toriba Veículos Volkswagen"},"message":"message","description":"description","transferred_path":{"from":"toribapompeia","id":"123leadid"}}}'

'{"lead":{"customer":{"name":"customer name","email":"customer email","phone":"customer phone"},"product":{"name":"product name"},"source":{"name":"Facebook - Toriba Veículos Volkswagen"},"message":"message","description":"description","transferred_path":{"from":"toribapompeia","id":"123leadid"}}}'

'{"lead":{"message":"message","description":"description","customer":{"name":"customer name","email":"customer email","phone":"customer phone"},"product":{"name":"product name"},"transferred_path":{"from":"toribapompeia","id":"123leadid"},"source":{"name":"Facebook - Toriba Veículos Volkswagen"}}}'
