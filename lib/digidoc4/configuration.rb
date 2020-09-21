# frozen_string_literal: true

module DigiDoc4
  ##
  # Configuration class for DigiDoc
  class Configuration
    attr_accessor :relying_party_uuid, :relying_party_name, :smart_id_base_url, :mobile_id_base_url

    def instance_variables_hash
      variables = {}
      instance_variables.map do |att|
        variables[att.to_s.sub('@', '')] = instance_variable_get(att)
      end

      variables
    end
  end
end
