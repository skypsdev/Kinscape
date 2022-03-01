require 'singleton'
require 'yaml'

class S3Config
  include Singleton

  def self.base_url
    instance.base_url
  end

  def self.bucket
    instance.bucket
  end

  def self.cloudfront_endpoint
    instance.cloudfront_endpoint
  end

  def base_url
    config['base_url']
  end

  def bucket
    config[env]['bucket']
  end

  def cloudfront_endpoint
    config[env]['cloudfront_base']
  end

  private

  def config
    @config ||= YAML.load_file('config/s3.yml')
  end

  def env
    ENV['RAILS_ENV'] || 'development'
  end
end
