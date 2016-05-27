require 'fedex/request/base'

module Fedex
  module Request
    module XML
      class SignatureProofOfDelivery < Base
        attr_accessor :builder, :credentials, :letter_format, :packge_type, :tracking_number

        def self.build(options)
          @xml = new options
          @xml.builder
          @xml.to_xml 
        end

        def initialize(options)
          @package_type  = options[:package_type]
          @letter_format = options[:letter_format]
          @credentials   = options[:credentials]
          @tracking_number   = options[:tracking_number]
        end

        def builder
          @builder = Nokogiri::XML::Builder.new do |xml|
            xml.SignatureProofOfDeliveryLetterRequest(xmlns: "http://fedex.com/ws/track/v#{service[:version]}" ) {
              add_web_authentication_detail xml
              add_client_detail xml
              add_version xml
              add_package_identifier xml
              xml.LetterFormat letter_format
            }
          end
        end

        def service
          { :id => 'trck', :version => 10 }
        end

        def package_type_valid?
          Fedex::TrackingInformation::PACKAGE_IDENTIFIER_TYPES.include? package_type
        end

        def add_package_identifier(xml)
          xml.QualifiedTrackingNumber do
            xml.TrackingNumber tracking_number
            xml.Destination{
              xml.CountryCode "US"
            }
          end
        end

        def to_xml
          @builder.doc.root.to_xml
        end

      end
    end
  end
end
