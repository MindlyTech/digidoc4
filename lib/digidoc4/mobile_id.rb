# frozen_string_literal: true

module DigiDoc4

  class MobileID < DigiDoc

    attr_reader :phone

    @base_url = ENV['']
    @required_vars = %i[phone]

    def initialize(input)
      raise ArgumentError unless @required_vars.all? { |param| input.key?(param) }

      super input
    end

    def authenticate_url
      "#{@base_url}/authentication"
    end

    def certificate_url
      "#{@base_url}/certificate"
    end

    def status_url(session_id, type)
      "#{@base_url}/session/#{type}/#{session_id}?timeoutMs=5000"
    end

    def sign_url
      "#{@base_url}/signature"
    end

    def body
      {
        id_code: @id_code,
        phone: @phone,
        language: case @phone[0, 4]
                  when '+372'
                    'EST'
                  when '+371'
                    'LAV'
                  when '+370'
                    'LIT'
                  else
                    'ENG'
                  end
      }.merge **relying_party, **hash
    end

    def get_cert
      res = HTTParty.post(
          certificate_url,
          body: body,
          headers: { 'Content-Type' => 'application/json' }
      )

      check_for_errors(res)

      response = JSON.parse(res.body)
      raise ArgumentError.new "No certificate for the user was found!" unless response[:result] == "OK"

      response[:cert]
    end

  end
end
