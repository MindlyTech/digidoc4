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
  conf.relying_party_uuid = '00000000-0000-0000-0000-000000000000'
  conf.relying_party_name = 'DEMO'
  conf.smart_id_base_url  = 'https://sid.demo.sk.ee/smart-id-rp/v1/'
  conf.mobile_id_base_url = 'https://tsp.demo.sk.ee/mid-api'
end
