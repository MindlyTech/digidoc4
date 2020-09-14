require "bundler/setup"
require "digidoc4"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

DigiDoc4.configure do |conf|
  conf.relying_party_uuid = 'TestUUID'
  conf.relying_party_name = 'TestName'
  conf.smart_id_base_url  = 'SmartIDTestURL'
  conf.mobile_id_base_url = 'MobileIDTestURL'
end
