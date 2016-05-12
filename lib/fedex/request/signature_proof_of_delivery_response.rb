require "fedex/helpers"

module Fedex
  module Request
    class SignatureProofOfDeliveryResponse
      include Fedex::Helpers
      attr_accessor :package_id, :credentials

      def initialize(response, credentials, package_id)
        @raw_response =response
        @credentials = credentials
        @package_id = package_id
        @response = parse_response
      end

      def parse_response
        sanitize_response_keys @raw_response
      end

      # Recursively sanitizes the response object by cleaning up any hash keys.
      def sanitize_response_keys(response)
        if response.is_a?(Hash)
          response.inject({}) { |result, (key, value)| result[underscorize(key).to_sym] = sanitize_response_keys(value); result }
        elsif response.is_a?(Array)
          response.collect { |result| sanitize_response_keys(result) }
        else
          response
        end
      end

      def letter
        @response[:signature_proof_of_delivery_letter_reply][:letter]
      end

      def success?
        has_reply? && acceptable_response?
      end

      def acceptable_response?
        %w{SUCCESS WARNING NOTE}.include?(highest_severity)
      end

      def highest_severity
        @response[:track_reply][:highest_severity]
      end

      def track_details
        @response[:track_reply][:track_details]
      end

      def has_reply?
        @response.key? :track_reply
      end

      def duplicate_waybill?
        @response[:track_reply][:duplicate_waybill].downcase == 'true'
      end

      def details
        @details ||= parse_waybill_shipments || parse_tracking_information
      end

      def parse_waybill_shipments
        if duplicate_waybill?
          shipments = []

          [track_details].flatten.map do |info|
            options = {:tracking_number => package_id, :uuid => info[:tracking_number_unique_identifier]}
            shipments << Request::TrackingInformation.new(credentials, options).process_request
          end

          shipments.flatten
        end
      end

      def parse_tracking_information
        [track_details].flatten.map  { |d| Fedex::TrackingInformation.new d }
      end


      def error_message
        @error_message ||=
          if has_reply?
            @response[:track_reply][:notifications][:message]
          else
            "#{failure_reason}\n--#{failure_details.join("\n--")}"
          end 

      rescue $1

      end

      def failure_reason
        @raw_response["Fault"]["detail"]["fault"]["reason"]
      end

      def failure_details
        @raw_response["Fault"]["detail"]["fault"]["details"]["ValidationFailureDetail"]["message"]
      end
    end
  end
end
