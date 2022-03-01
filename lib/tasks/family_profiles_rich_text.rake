namespace :family_profiles_rich_text do
  desc 'Encrypts family profiles rich text'
  task encrypt: :environment do
    raise 'Encryption is disabled' unless EncryptedActionText.configuration.encrypt

    encryption_method = EncryptedActionText.configuration.encryption_method

    ActionText::RichText.where(
      name: 'profile',
      record_type: 'Family'
    ).each do |rich_text|
      next if rich_text.body.blank?

      begin
        JSON.parse(rich_text.body.to_html)
        puts 'Already encrypted'
      rescue JSON::ParserError
        rich_text.update_column(
          :body, encryption_method.call(rich_text.body.to_html)
        )
      end
    end

    puts 'All Done!'
  end

  desc 'Decrypts family profiles rich text'
  task decrypt: :environment do
    raise 'Encryption is enabled' if EncryptedActionText.configuration.encrypt

    decryption_method = EncryptedActionText.configuration.decryption_method

    ActionText::RichText.where(
      name: 'profile',
      record_type: 'Family'
    ).each do |rich_text|
      next if rich_text.body.blank?

      begin
        JSON.parse(rich_text.body.to_html)
        rich_text.update_column(
          :body, decryption_method.call(rich_text.body.to_html)
        )
      rescue JSON::ParserError
        puts 'Already decrypted'
      end
    end

    puts 'All Done!'
  end
end
