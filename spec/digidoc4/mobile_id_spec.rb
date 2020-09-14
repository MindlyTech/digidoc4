# frozen_string_literal: true

RSpec.describe DigiDoc4::MobileID do
  let(:input) do
    {
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

  let(:relying_hash) do
    {
      relyingPartyUUID: 'TestUUID',
      relyingPartyName: 'TestName'
    }
  end

  let(:hash) do
    {
      hash: 'TestHash',
      hashType: 'TestHashType'
    }
  end

  before do
    allow_any_instance_of(DigiDoc4::MobileID).to receive(:hash).and_return(hash)
    allow_any_instance_of(DigiDoc4::MobileID).to receive(:relying_party).and_return(relying_hash)
    allow_any_instance_of(DigiDoc4::MobileID).to receive(:check_for_error).and_return(nil)
  end

  describe '::initialize' do
    context 'when initializing with wrong input' do
      it do
        invalid_input = { test: 'invalid', test2: 'phone' }
        expect { DigiDoc4::MobileID.new(invalid_input) }.to raise_error(ArgumentError)
      end
    end

    context 'when initializing with correct input' do
      it { expect(valid_mobile_id).to be_an_instance_of(DigiDoc4::MobileID) }
    end
  end

  describe '#verification_code' do
    context 'When hash is not set' do
      it { expect { valid_mobile_id.verification_code }.to raise_error(ArgumentError) }
    end

    context 'When hash is set' do
      it 'returns four digit integer' do
        valid_mobile_id.set_hash(SecureRandom.hex(32))

        vc = valid_mobile_id.verification_code

        expect(vc).to be_a_kind_of(Integer)
        expect(vc.to_s.length).to eq(4)
      end
    end
  end

  describe '#body' do
    context 'when method is called' do
      it 'should return body merged with relying party' do
        expect(valid_mobile_id.body.keys)
          .to include(:nationalIdentityNumber, :phoneNumber, :language, :relyingPartyUUID, :relyingPartyName)
      end

      it 'should return body with correct hash' do
        expect(valid_mobile_id.body).to include(relying_hash.merge(hash))
      end

      it 'should have correct language dependent on phone number' do
        expect(valid_mobile_id.body[:language]).to eq('EST')
      end
    end
  end

  describe '#authenticate_url' do
    context 'when method is called' do
      it 'should return a valid url' do
        expect(valid_mobile_id.authenticate_url).to eq('MobileIDTestURL/authentication')
      end
    end
  end

  describe '#status_url' do
    context 'when method is called with a type' do
      it 'should return a valid url' do
        expect(valid_mobile_id.status_url('TestID', 'signature'))
          .to eq('MobileIDTestURL/session/signature/TestID?timeoutMs=5000')
      end
    end

    context 'when method is called with an incorrect type' do
      it do
        expect { valid_mobile_id.status_url('TestID', 'some_stuff') }
          .to raise_error(ArgumentError, 'Incorrect type for status!')
      end
    end

    context 'when method is called without a type' do
      it do
        expect { valid_mobile_id.status_url('TestID', nil) }
          .to raise_error(ArgumentError, 'Incorrect type for status!')
      end
    end
  end

  describe '#sign_url' do
    context 'when method is called' do
      it 'should return a valid url' do
        expect(valid_mobile_id.sign_url).to eq('MobileIDTestURL/signature')
      end
    end
  end

  describe '#digidoc_cert' do
    context 'when response result is OK' do
      it do
        allow(HTTParty).to receive(:post).and_return(response_ok)
        expect(valid_mobile_id.digidoc_cert).to eq(JSON.parse(response_body_ok))
      end
    end

    context 'when response result is NOT_FOUND' do
      it do
        allow(HTTParty).to receive(:post).and_return(response_not_found)
        expect { valid_mobile_id.digidoc_cert }.to raise_error(DigiDoc4::DigiDoc::ValidationError)
      end
    end
  end
end
