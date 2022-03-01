EncryptedActionText.configure do |config|
  config.encrypt = false unless Rails.env.staging? || Rails.env.production?

  if Object.const_defined?('AttrKMS')
    config.encryption_method = ->(body) { AttrKMS.encrypt plaintext: body }
    config.decryption_method = ->(body) { AttrKMS.decrypt json: body }
  end
end
