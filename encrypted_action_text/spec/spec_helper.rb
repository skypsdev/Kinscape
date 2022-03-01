require 'bundler/setup'
Bundler.setup

require 'encrypted_action_text'

EncryptedActionText.configure do |config|
  config.encryption_method = ->(body) { Base64.encode64(body) }
  config.decryption_method = ->(body) { Base64.decode64(body) }
end
