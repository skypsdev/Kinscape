# rubocop:disable all
desc 'Migrate vault files to Active Storage'
task vault_to_active_storage: :environment do
  Attachment.where(containable_type: 'Vault').includes(:media_file).find_each do |attachment|
    vault = attachment.containable
    media_file = attachment.media_file
    next if media_file.migrated
    
    filestack_url = media_file&.url
    next unless filestack_url

    puts 'Downloading from Filestack'
    puts filestack_url


    tempfile = File.open("tmp/temp-attachment-#{attachment.id}", 'wb') do |file|
      file << URI.parse(filestack_url).read
    end

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(tempfile.path),
      filename: media_file.filename,
      content_type: media_file.mimetype
    )

    blob.attachments.create!(
      name: 'files',
      record: vault,
      box_id: attachment.box_id,
      user_id: media_file.user_id,
      family_id:  vault.owner_type == 'Family' ? vault.owner_id  : nil
    )
    media_file.update!(migrated: true)
    FileUtils.remove(tempfile)

  rescue StandardError => e
    attachment.media_file&.update!(migration_error: e.message)
    puts "Something went wrong while migrating attachment: ID #{attachment.id}"
    puts attachment.media_file&.url
    puts e.message
    next
  end
end
# rubocop:enable all
