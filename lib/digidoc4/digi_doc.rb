# frozen_string_literal: true

module DigiDoc4
  ##
  # This is the root class for all DigiDoc4 actions
  class DigiDoc
    ##
    # This error gets called when request fails
    class ValidationError < StandardError
      def initialize(input)
        super
        input.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    ##
    # Initializes the DigiDoc class
    #   legal Inputs:
    #     relying_party_uuid  - SK provided uuid
    #     relying_party_name  - SK proviced name
    #     base_url            - Base url for the service
    #     identity_code       - ID code for the user
    def initialize(input)
      input.each { |k, v| instance_variable_set("@#{k}", v) }

      rv = %w[@relying_party_uuid @relying_party_name @base_url @identity_code]
      rv -= instance_variables.map(&:to_s)

      raise ArgumentError, "Missing input variable(s): [\"#{rv.join('", "')}\"]" unless rv.empty?
    end

    ##
    # This sets the hash and hash type of the data that will be signed
    def set_hash(hash, hash_type = 'SHA256')
      @hash = hash
      @hash_type = hash_type
    end

    ##
    # This returns hash and hash_type inside the hash
    def hash
      { hash: @hash, hashType: @hash_type }
    end

    ##
    # This retuns relying_party_uuid and relying_party_name inside a hash
    def relying_party
      { relyingPartyName: @relying_party_name, relyingPartyUUID: @relying_party_uuid }
    end

    ##
    # Use this method to sing in with user
    def authenticate
      res = HTTParty.post(
        url,
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      JSON.parse(res.body)
    end

    ##
    # Use this method to get cert
    def cert
      @cert || get_cert
    end

    ##
    # use this method to start the process of file signing
    def sign
      res = HTTParty.post(
        sign_url,
        body: body,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      JSON.parse(res.body)
    end

    ##
    # use this method to get the status of the session
    #   params:
    #     session_id  - Session you want to get status of
    #     type        - ENUM[signature authentication], type of the session
    #
    def get_status(session_id, type)
      raise ArgumentError, "Type: \"#{type}\" is invalid" unless %w[signature authentication].include? type.downcase

      url = status_url(session_id, type)
      res = HTTParty.get(url)

      res = HTTParty.get(url) while JSON.parse(res.body)[:state] == 'RUNNING'

      check_for_error(res)

      JSON.parse(res.body)
    end

    private

    ##
    # Use it to check if http response is error
    def check_for_error(res)
      raise ValidationError.new(JSON.parse(res.body)), "Authentication failed with status code \"#{res.code}\"" if res.code != 200
    end
  end
end
