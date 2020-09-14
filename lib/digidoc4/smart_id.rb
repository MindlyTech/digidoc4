# frozen_string_literal: false

module DigiDoc4
  ##
  # This is the root class for all DigiDoc4 actions
  class SmartID < DigiDoc
    ##
    # Initializes the DigiDoc class
    #   legal Inputs:
    #     country_code = example: EE, LT, LV, KZ
    def initialize(input)
      super

      rv = %w[@country_code]
      rv -= instance_variables.map(&:to_s)

      raise ArgumentError, "Missing input variable(s): [\"#{rv.join('", "')}\"]" unless rv.empty?
    end

    ##
    # Generates the smart id sign in url that is used in the post request
    def authenticate_url
      "#{@base_url}/authentication/pno/#{@country_code}/#{@identity_code}"
    end

    ##
    # Generates smart id status url used to get status
    #   inputs:
    #     session_id  = session_id
    #     _           = nil input for mobileID
    def status_url(session_id, _)
      "#{@base_url}/session/#{session_id}?timeoutMs=5000"
    end

    ##
    # Generates smart id signing url used to get status
    def sign_url
      "#{@base_url}/signature/document/#{@document_number}"
    end

    ##
    # Generates the smart id sign in body that is used in the post request
    def body
      get_hash.merge get_relying_party
    end

    ##
    # Returns the certificate for that client
    def digidoc_cert
      res = HTTParty.post(
        "#{@base_url}certificatechoice/pno/#{@country_code}/#{@identity_code}",
        body: get_relying_party,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      res = JSON.parse(res.body)
      res = get_status(res['sessionId'], 'authentication')

      @document_number = res['documentNumber']
      @cert = res['cert']['value']
      return res
    end
  end
end
