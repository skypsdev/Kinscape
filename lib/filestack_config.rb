require 'openssl'

class FilestackConfig
  private_class_method :new
  attr_reader :policy, :signature

  URL_REGEX = /\A((cdn)|(www))\.((filepicker)|(filestackcontent))\.((com)|
    (io))\z/x.freeze

  class << self
    def upload
      policy = {
        expiry: 30.minutes.from_now.to_i,
        call: %w(pick store runWorkflows read)
      }
      new(policy)
    end

    def view(handle)
      policy = {
        handle: handle,
        call: %w(read),
        expiry: 30.minutes.from_now.to_i
      }
      new(policy)
    end

    def convert(handle)
      policy = {
        handle: handle,
        call: %w(exif convert store),
        expiry: 1.minute.from_now.to_i
      }
      new(policy)
    end

    def with_view_config(url)
      return url if url.blank? || url.start_with?('/rails/')

      url = url.split('?')[0]
      uri = URI.parse(url)
      if URL_REGEX.match?(uri.host)
        config = view(uri.path[1..].delete_prefix('api/file/'))
        params = { 'policy' => config.policy, 'signature' => config.signature }
        uri.query = URI.encode_www_form(params)
      end
      uri.to_s
    end
  end

  def initialize(policy)
    secret = Rails.env.test? ? nil : ENV['FILESTACK_SECRET']
    return if secret.nil?

    @policy = Base64.urlsafe_encode64(policy.to_json)
    @signature = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), secret, @policy)
  end
end
