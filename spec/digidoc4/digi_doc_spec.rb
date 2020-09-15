# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

RSpec.describe DigiDoc4::DigiDoc do
  let(:input) do
    {
      identity_code: 'TestIdentityCode'
    }
  end

  let(:valid_digidoc) { DigiDoc4::DigiDoc.new(input) }

  let(:response_body) { '{ "sessionId": "de305d54-75b4-431b-adb2-eb6b9e546015" }' }
  let(:response)      { instance_double(HTTParty::Response, code: 200, body: response_body) }
  let(:err_response)  { instance_double(HTTParty::Response, code: 500, body: response_body) }

  describe '::initialize' do
    context 'valid input should return instance of DigiDoc' do
      it { expect(valid_digidoc).to be_an_instance_of(DigiDoc4::DigiDoc) }
    end

    context 'when inputs are missing shoudl throw ArgumentError' do
      it { expect { DigiDoc4::DigiDoc.new(hash: 'false') }.to raise_error(ArgumentError) }
    end
  end

  describe '#set_hash' do
    context 'should set hash and use default hash_type' do
      it do
        dd = valid_digidoc
        dd.set_hash('TestHashTrue')

        expect(dd.instance_variable_get(:@hash)).to eq('TestHashTrue')
        expect(dd.instance_variable_get(:@hash_type)).to eq('SHA256')
      end
    end

    context 'should set hash and hash_type' do
      it do
        dd = valid_digidoc
        dd.set_hash('TestHashTrue', 'TestHashTypeTrue')

        expect(dd.instance_variable_get(:@hash)).to eq('TestHashTrue')
        expect(dd.instance_variable_get(:@hash_type)).to eq('TestHashTypeTrue')
      end
    end
  end

  describe '#hash' do
    context 'should get hash and hash_type' do
      it do
        dd = valid_digidoc
        dd.instance_variable_set(:@hash, 'Testhash')
        dd.instance_variable_set(:@hash_type, 'TestHashType')

        expect(dd.hash).to eq(hash: 'Testhash', hashType: 'TestHashType')
      end
    end
  end

  describe '#relying_party' do
    context 'should get relying_party_name and relying_party_uuid' do
      it do
        dd = valid_digidoc

        expect(dd.relying_party).to eq(relyingPartyUUID: 'TestUUID', relyingPartyName: 'TestName')
      end
    end
  end

  describe '#authenticate' do
    context 'when request is done' do
      it do
        allow(HTTParty).to receive(:post).and_return(response)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:authenticate_url)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:body)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:check_for_error).with(response).and_return(nil)

        expect(valid_digidoc.authenticate).to eq({ 'sessionId' => 'de305d54-75b4-431b-adb2-eb6b9e546015' })
      end
    end
  end

  describe '#cert' do
    context 'When @cert is set' do
      it do
        expect_any_instance_of(DigiDoc4::DigiDoc).not_to receive(:digidoc_cert)
        expect(DigiDoc4::DigiDoc.new(input.merge({ cert: 'TestCert' })).cert).to eq('TestCert')
      end
    end

    context 'When @cert is not set' do
      it do
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:digidoc_cert).and_return(nil)
        expect_any_instance_of(DigiDoc4::DigiDoc).to receive(:digidoc_cert)
        valid_digidoc.cert
      end
    end
  end

  describe '#sign' do
    context 'when request is done' do
      it do
        allow(HTTParty).to receive(:post).and_return(response)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:sign_url)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:body)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:check_for_error).with(response).and_return(nil)

        expect(valid_digidoc.sign).to eq({ "sessionId" => "de305d54-75b4-431b-adb2-eb6b9e546015" })
      end
    end
  end

  describe '#get_status' do
    context 'when type isn\'t valid' do
      it { expect { valid_digidoc.get_status('TestSessionID', 'FalseType') }.to raise_error(ArgumentError) }
    end

    context 'when request is done' do
      it do
        allow(HTTParty).to receive(:get).and_return(response)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:status_url)
        allow_any_instance_of(DigiDoc4::DigiDoc).to receive(:check_for_error).with(response).and_return(nil)

        expect(valid_digidoc.get_status('TestSession', 'authentication')).to eq({ "sessionId" => "de305d54-75b4-431b-adb2-eb6b9e546015" })
      end
    end
  end

  describe '#check_for_error' do
    context 'When input response is 200' do
      it { expect(valid_digidoc.send(:check_for_error, response)).to eq(nil) }
    end

    context 'When input response is not 200' do
      it do
        expect { valid_digidoc.send(:check_for_error, err_response) }.to raise_error(DigiDoc4::DigiDoc::ValidationError)
      end
    end
  end
end
