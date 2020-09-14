# frozen_string_literal: true

module DigiDoc4

  ##
  # This is the class for interacting with Mobile-ID REST API service
  class MobileID < DigiDoc

    attr_reader :phone

    def initialize(input)
      required_vars = %i[phone]
      missing_vars = []
      required_vars.each { |p| missing_vars << p unless input.key?(p) }
      unless missing_vars.empty?
        raise ArgumentError, "Missing input variable(s) for Mobile-ID: #{missing_vars.join(', ')}"
      end

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
      lang = case @phone[0, 4]
             when '+372'
               'EST'
             when '+371'
               'LAV'
             when '+370'
               'LIT'
             else
               'ENG'
             end

      {
        nationalIdentityNumber: @identity_code,
        phoneNumber: @phone,
        language: lang
      }.merge(**relying_party, **hash)
    end

    def digidoc_cert
      res = HTTParty.post(
        certificate_url,
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      response = JSON.parse(res.body)
      if response['result'] != 'OK'
        raise DigiDoc4::DigiDoc::ValidationError.new(hash: 'No certificate for the user was found!')
      end

      @cert = response['cert']
      response
    end

  end
end