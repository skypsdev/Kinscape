module EncryptedActionText
  module Attribute
    extend ActiveSupport::Concern

    class_methods do
      # Provides access to a dependent EncryptedRichText model that holds the body and attachments for a single named rich text attribute.
      # This dependent attribute is lazily instantiated and will be auto-saved when it's been changed. Example:
      #
      #   class Message < ActiveRecord::Base
      #     has_encrypted_rich_text :content
      #   end
      #
      #   message = Message.create!(content: "<h1>Funny times!</h1>")
      #   message.content.to_s # => "<h1>Funny times!</h1>"
      #   message.content.to_plain_text # => "Funny times!"
      #
      # The dependent EncryptedRichText model will also automatically process attachments links as sent via the Trix-powered editor.
      # These attachments are associated with the RichText model using Active Storage.
      #
      # If you wish to preload the dependent EncryptedRichText model, you can use the named scope:
      #
      #   Message.all.with_encrypted_rich_text_content # Avoids N+1 queries when you just want the body, not the attachments.
      #   Message.all.with_encrypted_rich_text_content_and_embeds # Avoids N+1 queries when you just want the body and attachments.
      #
      # rubocop:disable Naming/PredicateName
      def has_encrypted_rich_text(name)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{name}
            rich_text_#{name} || build_rich_text_#{name}
          end

          def #{name}=(body)
            self.#{name}.body = body
          end
        CODE

        class_name = if EncryptedActionText.configuration.encrypt
                       'EncryptedActionText::RichText'
                     else
                       'ActionText::RichText'
                     end

        # rubocop:disable Rails/ReflectionClassName
        has_one :"rich_text_#{name}", -> { where(name: name) },
                class_name: class_name, as: :record,
                inverse_of: :record, autosave: true, dependent: :destroy
        # rubocop:enable Rails/ReflectionClassName

        scope :"with_rich_text_#{name}", -> {
          includes("rich_text_#{name}")
        }
        scope :"with_rich_text_#{name}_and_embeds", -> {
          includes("rich_text_#{name}": { embeds_attachments: :blob })
        }
      end
    end
    # rubocop:enable Naming/PredicateName
  end
end
