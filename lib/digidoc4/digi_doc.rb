
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
  end
end
