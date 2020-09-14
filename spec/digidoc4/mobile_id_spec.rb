# frozen_string_literal: true

RSpec.describe DigiDoc4::MobileID do
  let(:input) do
    {
        relying_party_uuid: 'TestUUID',
        relying_party_name: 'TestName',
        base_url: 'TestBaseURL',
        identity_code: 'TestIdentityCode',
        phone: '+37255555555'
    }
  end

  let(:valid_mobile_id) { DigiDoc4::MobileID.new(input) }
  let(:response_body_ok) do
    '{ "result": "OK", "cert": "aAbBcCdDeEfF", "time": "2019-07-23T11:32:01", "traceId": "5ffc28098bb14341" }'
  end

  let(:response_body_not_found) { '{ "result": "NOT_FOUND" }' }
  let(:response_ok)        { instance_double(HTTParty::Response, code: 200, body: response_body_ok) }
  let(:response_not_found) { instance_double(HTTParty::Response, code: 200, body: response_body_not_found) }
  let(:err_response)       { instance_double(HTTParty::Response, code: 500, body: response_body_ok) }

  context '#initialize' do
    it 'should raise an error if required vars for mobile-id are not set' do
      invalid_input = { test: 'invalid', test2: 'phone' }

      expect { DigiDoc4::MobileID.new(invalid_input) }.to raise_error(ArgumentError)
    end

    it 'should raise an error if common required vars are not set' do
      invalid_input = { phone: '+3725555555', identity_code: '3541551562' }

      expect { DigiDoc4::MobileID.new(invalid_input) }.to raise_error(ArgumentError)
    end

    it 'valid input should return instance of DigiDoc' do
      expect(valid_mobile_id).to be_an_instance_of(DigiDoc4::MobileID)
    end
  end

  context '#body' do
    it 'should return body merged with relying party info even if hash is not set' do
      expect(valid_mobile_id.body).to include(:nationalIdentityNumber, :phoneNumber,
                                              :language, :relyingPartyUUID, :relyingPartyName)
    end

    it 'should have correct language dependent on phone number' do
      expect(valid_mobile_id.body[:language]).to eq('EST')
    end

    it 'should return body with correct hash' do
      valid_mobile_id.set_hash('aAbBcCdDeEfF', 'SHA512')

      expect(valid_mobile_id.body[:hash]).to eq('aAbBcCdDeEfF')
      expect(valid_mobile_id.body[:hashType]).to eq('SHA512')
    end
  end

  context '#digidoc_cert' do
    it 'should return certificate if response result is OK' do
      allow(HTTParty).to receive(:post).and_return(response_ok)
      expect(valid_mobile_id.digidoc_cert).to eq(JSON.parse(response_body_ok))
    end

    it 'should raise correct error if response result is NOT_FOUND' do
      allow(HTTParty).to receive(:post).and_return(response_not_found)
      expect { valid_mobile_id.digidoc_cert }.to raise_error(ArgumentError, 'No certificate for the user was found!')
    end

    it 'should raise correct error if response is not 200' do
      expect { valid_mobile_id.send(:check_for_error, err_response) }.to raise_error(DigiDoc4::DigiDoc::ValidationError)
    end
  end
end