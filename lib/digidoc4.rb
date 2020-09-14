# frozen_string_literal: true

require_relative 'digidoc4/version'
require_relative 'digidoc4/configuration'
require_relative 'digidoc4/digi_doc'
require_relative 'digidoc4/mobile_id'
require_relative 'digidoc4/smart_id'

require 'httparty'
require 'json'

##
# This is DigiDoc module base
module DigiDoc4
  class Error < StandardError; end

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end
end
