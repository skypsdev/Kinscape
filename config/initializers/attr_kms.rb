if Object.const_defined?('AttrKMS')
  AttrKMS.configure do |config|
    config.cmk_key_id = ENV['AKMS_CMK_KEY_ID']
    config.cmk_key_spec = 'AES_256'
    config.aws_region = ENV['AWS_REGION']
    config.access_key_id = ENV['S3_KEY']
    config.secret_access_key = ENV['S3_SECRET']
    config.openssl_key_spec = 'aes-256-gcm'
  end
end
