require 'fedex/request/base'
require 'fedex/request/xml/signature_proof_of_delivery'
require 'fedex/request/signature_proof_of_delivery_response'

module Fedex
  module Request
    class SignatureProofOfDelivery < Fedex::Request::Base
      LETTER_FORMATS = { pdf: "PDF", png: "PNG" }
      Template = Fedex::Request::XML::SignatureProofOfDelivery
      Response = Fedex::Request::SignatureProofOfDeliveryResponse

      attr_reader :api_response, :credentials, :package_type, :package_id, :tracking_number, :letter_format

      def initialize(credentials, options={})
        @tracking_number   = options[:tracking_number]
        @letter_format = options[:letter_format] || LETTER_FORMATS[:pdf]
        @uuid = options[:uuid]
        @country_code = "US"
        @credentials  = credentials

        # Optional
        @include_detailed_scans = options[:include_detailed_scans] || true
        @ship_date              = options[:ship_date]
        @paging_token           = options[:paging_token]
      end

      def process_request
        @api_response ||= Response.new api_request, @credentials, @tracking_number
      end


      # Build xml Fedex Web Service request
      def build_xml
        @xml ||= Template.build credentials: credentials, letter_format: letter_format, package_type: package_type, tracking_number: tracking_number
      end

      def letter
        @letter ||= @api_response.letter
      end
    end
  end
end
