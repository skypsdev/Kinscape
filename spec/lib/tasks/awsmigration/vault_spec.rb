require 'spec_helper'
require 'rake'
Rails.application.load_tasks
# rubocop:disable all
describe Rake::Task do
  subject(:result) { described_class[:vault_to_active_storage].invoke }

  let(:admin) { create :user }
  let(:admin_vault) { admin.vault }
  let(:family) { create :family, users: [admin] }
  let(:family_vault) { create :vault, owner: family }
  let(:admin_box) { create :box, vault: admin_vault }
  let(:family_box) { create :box, vault: family_vault }
  let(:private_media_file) do
    create :media_file, user: admin, url: 'https://cdn.filestackcontent.com/YcJxeskwRYONTMZ1gHSI'
  end
  let(:broken_link_file) do
    create :media_file, user: admin, url: 'https://www.filepicker.io/api/file/adPBa0WRySO4fxUYJOXg'
  end
  let(:family_media_file) do
    create :media_file, user: admin, url: 'https://cdn.filestackcontent.com/eL0UiHSYTyW5XovlcouK'
  end


  before do
    create :attachment, media_file: private_media_file, containable: admin_vault, box: admin_box
    create :attachment, media_file: family_media_file, containable: family_vault, box: family_box
    create :attachment, media_file: broken_link_file, containable: family_vault
  end

  it 'create new attachments and blobs' do
    silent_puts
    VCR.use_cassette('lib/vault_rake_task') do
      expect { result }.to change { family_vault.reload.files.size }
        .by(1)
        .and change { admin_vault.reload.files.size }
        .by(1)

      expect(private_media_file.reload.migrated).to eq(true)
      new_private_attachment = admin_vault.files.first
      expect(new_private_attachment.box_id).to eq(admin_box.id)
      expect(new_private_attachment.user_id).to eq(admin.id)
      expect(new_private_attachment.family_id).to be_nil

      expect(family_media_file.reload.migrated).to eq(true)
      new_family_attachment = family_vault.files.first
      expect(new_family_attachment.box_id).to eq(family_box.id)
      expect(new_family_attachment.user_id).to eq(admin.id)
      expect(new_family_attachment.family_id).to eq(family.id)

      expect(broken_link_file.reload.migrated).to eq(false)
      expect(broken_link_file.migration_error).to eq('404 Not Found')
    end
  end
end
# rubocop:enable all
