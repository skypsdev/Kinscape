module EncryptedActionText
  # The RichText record holds the content produced by the Trix editor in a serialized +body+ attribute.
  # It also holds all the references to the embedded files, which are stored using Active Storage.
  # This record is then associated with the Active Record model the application desires to have
  # rich text content using the +has_rich_text+ class method.
  # We're serializing it with our encrypted content serializer.
  class RichText < ActionText::RichText
    serialize :body, EncryptedActionText::Content
  end
end

ActiveSupport.run_load_hooks :encrypted_action_text_rich_text,
                             EncryptedActionText::RichText
