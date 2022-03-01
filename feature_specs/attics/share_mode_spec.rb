require 'spec_helper'

feature 'Share mode', :js do
  include AtticsPageHelpers

  let!(:family_1) { create :family, name: 'Smiths' }
  let!(:family_2) { create :family, name: 'Purrkins' }

  let!(:connector)     { create :user, families: [family_1, family_2] }
  let!(:family_member) { create :user, families: [family_1, family_2] }

  let!(:box) { create :box, attic: family_member.private_attic, name: '1 box' }

  let!(:family_attic_1) { create :attic, family: family_1, user: connector }
  let!(:family_attic_2) { create :attic, family: family_2, user: connector }
  let!(:private_attic)  { connector.private_attic }

  let(:media_file_1) { create :document_media_file, user: connector }
  let(:media_file_2) { create :document_media_file, user: connector }
  let(:media_file_3) { create :document_media_file, user: family_member }

  let(:attachment_1) do
    create :attachment, media_file: media_file_1, created_at: '2014-01-10'
  end

  let(:attachment_2) do
    create :attachment, media_file: media_file_2, created_at: '2014-02-09'
  end

  let(:attachment_3) do
    create :attachment, media_file: media_file_3, created_at: '2014-02-10'
  end

  context 'when no files uploaded to the attic' do
    it 'hides "Share" mode button' do
      visit attic_path private_attic, as: connector

      expect(page).not_to have_link 'Share'
    end
  end

  context 'when sharing files to the family attic' do
    background do
      private_attic.attachments << [attachment_1, attachment_2, attachment_3]

      visit attic_path private_attic, as: connector
    end

    scenario 'switching to Share mode' do
      expect(page).to have_no_text 'Select files to share'
      expect(page).to have_no_css '#cancel-button'

      find('#share-button').click

      expect(page).to have_text 'Select files to share'
      expect(page).to have_no_css '#delete-button'
      expect(page).to have_css '#cancel-button'

      find('#cancel-button').click

      expect(page).to have_no_text 'Select files to share'
      expect(page).to have_no_css '#cancel-button'
    end

    scenario 'selecting files to be shared' do
      click_on 'Share'

      within file_group_selector(position: 1) do
        click_on_file position: 1
        selected_file_present position: 1
      end
    end

    scenario 'select family attic in attachments share modal' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
        selected_file_present position: 1
      end

      find('#share-button').click

      within '#share_between_attics_modal' do
        expect(page).to have_text 'Smiths Family Attic'
        expect(page).to have_no_text 'My Attic'

        expect(page).to have_css '#share-to:disabled'

        find('.attic-list-item:nth-child(1)').click

        expect(page).to have_css '#share-to:enabled'

        expect(page).to \
          have_css('.attic-list-item.current', text: 'Purrkins Family Attic')

        find('.attic-list-item:nth-child(2)').click

        expect(page).to \
          have_css('.attic-list-item.current', text: 'Smiths Family Attic')
      end
    end

    scenario 'tries to share nothing' do
      find('#share-button').click
      find('#share-button').click

      expect(page).to have_text(/You must select file\(s\)/i)

      click_on 'OK'
    end

    scenario 'deselecting selected files' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1

        click_on_file position: 1

        no_attachments_selected
      end
    end

    scenario 'files are deselected when Share mode is turned off' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#cancel-button').click

      no_attachments_selected

      find('#share-button').click

      no_attachments_selected
    end

    scenario 'sharing files to deleted family attic' do
      family_attic_1.destroy

      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#share-button').click

      within '#share_between_attics_modal' do
        find('.attic-list-item:nth-child(2)').click

        find('#share-to').click
      end

      expect(page).to have_text 'Could not perform action'
    end
  end

  context 'when family member shares files to the private attic' do
    background do
      family_attic_1.attachments << [attachment_1, attachment_2, attachment_3]

      visit attic_path family_attic_1, as: family_member
    end

    scenario 'show private attic only' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#share-button').click

      within '#share_between_attics_modal' do
        expect(page).to have_text 'My Attic'
        expect(page).to have_no_text 'Smiths Family Attic'
        expect(page).to have_no_text 'Purrkins Family Attic'
      end
    end

    scenario 'show all attachments in share mode' do
      find('#share-button').click

      file_previews_present count: 3
    end

    scenario 'successfully shared' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#share-button').click

      within '#share_between_attics_modal' do
        find('.attic-list-item:nth-child(1)').click

        find('#share-to').click
      end

      expect(page).to have_text 'File(s) shared successfully'

      visit attic_path family_member.private_attic

      within file_group_selector(position: 1) do
        file_previews_present count: 1
      end
    end

    scenario 'successfully shared to specific box' do
      find('#share-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#share-button').click

      within '#share_between_attics_modal' do
        find('.attic-list-item:nth-child(1)').click

        select_attic_box box

        find('#share-to').click
      end

      expect(page).to have_text 'File(s) shared successfully'

      visit attic_path family_member.private_attic

      select_attic_box box

      within file_group_selector(position: 1) do
        file_previews_present count: 1
      end
    end
  end
end
