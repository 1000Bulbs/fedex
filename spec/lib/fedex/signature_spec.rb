require 'spec_helper' 
require 'fedex/request/signature_proof_of_delivery'
module Fedex
  module Request
    describe SignatureProofOfDelivery do
      context "shipments with tracking number", :vcr, :focus do
        let(:options) do
          { :tracking_number => "783060754055"}
        end

        it "returns a decrypted letter" do
          credentials = Fedex::Credentials.new fedex_production_credentials
          request = Fedex::Request::SignatureProofOfDelivery.new(credentials, options).process_request
          expect(request.letter).not_to be_empty
        end

        describe "Bad tracking number" do
          it "returns nul" do
            options = { :tracking_number => "783158905288"}
            credentials = Fedex::Credentials.new fedex_production_credentials
            request = Fedex::Request::SignatureProofOfDelivery.new(credentials, options).process_request
            expect(request.letter).to be_nil
          end
          
        end
      end
    end
  end
end
