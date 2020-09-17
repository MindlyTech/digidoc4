# frozen_string_literal: true

RSpec.describe DigiDoc4::MobileID do
  let(:personal_data) do
    {
      identity_code: '60001018800',
      phone: '+37200000566'
    }
  end

  describe '#authenticate' do
    let(:hash) { Digest::SHA256.base64digest(SecureRandom.hex(32)) }

    context 'Valid Login' do
      it 'Successfully authenticate' do
        mid = DigiDoc4::MobileID.new(personal_data)
        mid.set_hash(hash)

        res = mid.authenticate
        session_id = res['sessionID']
        expect(session_id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)

        res = mid.get_status(session_id, 'authentication')
        expect(res).to include('state', 'result', 'signature', 'cert', 'time', 'traceId')
        expect(res['state']).to eq('COMPLETE')
        expect(res['result']).to eq('OK')
      end
    end
  end

  describe '#sign' do
    let(:hash) { Digest::SHA256.base64digest(SecureRandom.hex(32)) }

    context 'Valid signing' do
      it 'Successfully signs' do
        mid = DigiDoc4::MobileID.new(personal_data)
        mid.set_hash(hash)

        cert = mid.cert
        expect(cert).not_to eq(nil)

        res = mid.sign
        session_id = res['sessionID']
        expect(session_id).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)

        res = mid.get_status(session_id, 'signature')
        expect(res).to include('result', 'signature', 'time', 'traceId')
        expect(res['state']).to eq('COMPLETE')
        expect(res['result']).to eq('OK')
      end
    end
  end
end
