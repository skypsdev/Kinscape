require 'encrypted_action_text/engine'

require 'active_support'
require 'active_support/rails'

module EncryptedActionText
  extend ActiveSupport::Autoload

  autoload :Attribute
  autoload :Content

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :encryption_method, :decryption_method, :encrypt

    def initialize
      @encrypt = true
    end
  end
end
