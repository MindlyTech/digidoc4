# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength

RSpec.describe DigiDoc4::SmartID do
  let(:input) do
    {
      identity_code: 'TestIdentityCode',
      country_code: 'ee'
    }
  end

  let(:false_input) do
    {
      identity_code: 'TestIdentityCode'
    }
  end

  let(:relying_hash) do
    {
      relying_party_uuid: 'TestUUID',
      relying_party_name: 'TestName'
    }
  end

  let(:hash) do
    {
      hash: 'TestHash',
      hashType: 'TestHashType'
    }
  end

  let(:get_status_res) do
    '{ "documentNumber": "TestNumber",
      "cert": {
        "value": "certValue"
      }
    }'
  end

  let(:valid_smart_id) { DigiDoc4::SmartID.new(input) }

  let(:response_body) { '{ "sessionId": "de305d54-75b4-431b-adb2-eb6b9e546015" }' }
  let(:response)      { instance_double(HTTParty::Response, code: 200, body: response_body) }
  let(:err_response)  { instance_double(HTTParty::Response, code: 500, body: response_body) }

  before(:each) do
    allow_any_instance_of(DigiDoc4::SmartID).to receive(:get_hash).and_return(hash)
    allow_any_instance_of(DigiDoc4::SmartID).to receive(:get_relying_party).and_return(relying_hash)
    allow_any_instance_of(DigiDoc4::SmartID).to receive(:check_for_error).and_return(nil)
    allow_any_instance_of(DigiDoc4::SmartID).to receive(:get_cert).and_return(nil)
    allow_any_instance_of(DigiDoc4::SmartID).to receive(:get_status)
      .with('de305d54-75b4-431b-adb2-eb6b9e546015', 'authentication')
      .and_return(JSON.parse(get_status_res))

    allow(HTTParty).to receive(:post).and_return(instance_double(HTTParty::Response, code: 200, body: response_body))
  end

  describe '::initialize' do
    context 'valid input should return instance of DigiDoc' do
      it { expect(valid_smart_id).to be_an_instance_of(DigiDoc4::SmartID) }
    end

    context 'when inputs are missing shoudl throw ArgumentError' do
      it { expect { DigiDoc4::SmartID.new(false_input) }.to raise_error(ArgumentError) }
    end
  end

  describe '#authenticate_url' do
    context 'When method gets called' do
      it 'should return a valid url' do
        expect(valid_smart_id.authenticate_url).to eq('SmartIDTestURL/authentication/pno/ee/TestIdentityCode')
      end
    end
  end

  describe '#status_url' do
    context 'When method gets called' do
      it 'should return a valid url' do
        expect(valid_smart_id.status_url('TestID', nil)).to eq('SmartIDTestURL/session/TestID?timeoutMs=5000')
      end
    end
  end

  describe '#sign_url' do
    context 'When method gets called' do
      it 'should return a valid url' do
        valid_smart_id.instance_variable_set(:@document_number, 'TestNumber')
        expect(valid_smart_id.sign_url).to eq('SmartIDTestURL/signature/document/TestNumber')
      end
    end
  end

  describe '#body' do
    context 'when called' do
      it 'should merge together #get_hahs and  #get_relying_party' do
        expect(valid_smart_id.body).to eq(relying_hash.merge(hash))
      end
    end
  end

  describe '#digidoc_cert' do
    context 'when request is done' do
      it 'should return cert hash' do
        res = valid_smart_id.digidoc_cert
        expect(valid_smart_id.instance_variable_get(:@cert)).to eq('certValue')
        expect(valid_smart_id.instance_variable_get(:@document_number)).to eq('TestNumber')

        expect(res).to eq({ 'documentNumber' => 'TestNumber', 'cert' => { 'value' => 'certValue' }})
      end
    end
  end
end
