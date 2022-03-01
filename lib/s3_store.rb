require 's3_config'

class S3Store
  BUCKET = ::S3Config.bucket.freeze

  def initialize(file, name)
    @file = file
    @name = name
    @s3_client = AWS::S3.new(
      access_key_id: ENV['S3_KEY'],
      secret_access_key: ENV['S3_SECRET'],
      region: ENV['AWS_REGION']
    )
    @bucket = @s3_client.buckets[BUCKET]
  end

  def store(method: :body)
    @obj = @bucket.objects[@name].write(@file.send(method), acl: :public_read)
    self
  end

  def url
    @obj.public_url.to_s
  end
end
