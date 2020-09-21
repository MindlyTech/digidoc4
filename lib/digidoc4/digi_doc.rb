# frozen_string_literal: true

module DigiDoc4
  ##
  # This is the root class for all DigiDoc4 actions
  class DigiDoc
    ##
    # This error gets called when request fails
    class ValidationError < StandardError
      attr_accessor :error, :time, :traceId, :path
      def initialize(input)
        super
        input.each { |k, v| instance_variable_set("@#{k}", v) }
      end
    end

    ##
    # Initializes the DigiDoc class
    #   legal Inputs:
    #     identity_code       - ID code for the user
    def initialize(input)
      ##
      # Adds configuration params to input
      input.merge!(DigiDoc4.configuration.instance_variables_hash)

      ##
      # Adds input params to instance variabless
      input.each { |k, v| instance_variable_set("@#{k}", v) }

      ##
      # Sets base_url based on class instance
      @base_url = case self.class.name
                  when 'DigiDoc4::MobileID' then @mobile_id_base_url
                  when 'DigiDoc4::SmartID'  then @smart_id_base_url
                  end

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
        authenticate_url,
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      res.parsed_response
    end

    ##
    # Use this method to get cert
    def cert
      digidoc_cert if @cert.nil?
      @cert
    end

    ##
    # use this method to start the process of file signing
    def sign
      res = HTTParty.post(
        sign_url,
        body: body.to_json,
        headers: { 'Content-Type' => 'application/json' }
      )

      check_for_error(res)

      res.parsed_response
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

      res = HTTParty.get(url) while res.parsed_response['state'] == 'RUNNING'

      check_for_error(res)

      res.parsed_response
    end

    private

    ##
    # Use it to check if http response is error
    def check_for_error(res)
      body = res.parsed_response
      raise ValidationError.new(body), "Authentication failed\n    status code: \"#{res.code}\"\n    message: \"#{body['error']}\"" if res.code != 200
    end
  end
end
