module EncryptedActionText
  class Content < ActionText::Content
    class << self
      def load(content)
        super decrypt!(content)
      end

      def dump(content)
        encrypt! super(content)
      end

      private

      def encrypt!(content)
        return content if content.blank? || !encrypt

        encryption_method.call(content)
      end

      def decrypt!(content)
        return content if content.blank? || !encrypt

        decryption_method.call(content)
      end

      [:encryption_method, :decryption_method, :encrypt].each do |m|
        define_method(m) { EncryptedActionText.configuration.send(m) }
      end
    end
  end
end
