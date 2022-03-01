require 'spec_helper'

feature 'Move mode', :js do
  include AtticsPageHelpers

  let!(:user) { create :user }

  let!(:private_attic) { user.private_attic }

  let(:media_file_1) { create :document_media_file, user: user }
  let(:media_file_2) { create :document_media_file, user: user }

  let(:attachment_1) do
    create :attachment, media_file: media_file_1, created_at: '2014-01-10'
  end

  let(:attachment_2) do
    create :attachment, media_file: media_file_2, created_at: '2014-02-09'
  end

  context 'when no files uploaded to the attic' do
    before { create :box, attic: private_attic }

    it 'hides "Move" mode button' do
      visit attic_path private_attic, as: user

      expect(page).not_to have_link 'Move'
    end
  end

  context 'when no boxes created' do
    it 'hides "Move" mode button' do
      visit attic_path private_attic, as: user

      expect(page).not_to have_link 'Move'
    end
  end

  context 'when boxes present' do
    let!(:box_1) { create :box, attic: private_attic, name: 'First box' }
    let!(:box_2) { create :box, attic: private_attic, name: 'Second box' }

    let!(:attachment_from_box) do
      create :attachment,
             media_file: media_file_2, created_at: '2014-02-09', box: box_2
    end

    background do
      private_attic.attachments << [
        attachment_1,
        attachment_2,
        attachment_from_box
      ]

      visit attic_path private_attic, as: user
    end

    scenario 'switching to Move mode' do
      expect(page).to have_no_text 'Select files to move'
      expect(page).to have_no_css '#cancel-button'

      find('#move-button').click

      expect(page).to have_text 'Select files to move'
      expect(page).to have_no_css '#delete-mode-button'
      expect(page).to have_css '#cancel-button'

      find('#cancel-button').click

      expect(page).to have_no_text 'Select files to move'
      expect(page).to have_no_css '#cancel-button'
    end

    scenario 'selecting files to be moved' do
      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
        selected_file_present position: 1
      end
    end

    scenario 'tries to move nothing' do
      find('#move-button').click
      find('#move-button').click

      expect(page).to have_text(/You must select file\(s\)/i)

      click_on 'OK'
    end

    scenario 'deselecting selected files' do
      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1

        click_on_file position: 1

        no_attachments_selected
      end
    end

    scenario 'files are deselected when Move mode is turned off' do
      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#cancel-button').click

      no_attachments_selected

      find('#move-button').click

      no_attachments_selected
    end

    scenario 'moving files to deleted family attic' do
      box_1.destroy

      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#move-button').click

      within '#move_files_to_box_modal' do
        select_attic_box box_1
        find('#move-to-box').click
      end

      expect(page).to have_text 'Could not perform action'
    end

    scenario 'successfully moved files from attic to attic box' do
      within '.grouped-attachments' do
        file_previews_present count: 2
      end

      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#move-button').click

      within '#move_files_to_box_modal' do
        select_attic_box box_1
        find('#move-to-box').click
      end

      expect(page).to have_text 'File(s) moved successfully'

      within '.grouped-attachments' do
        file_previews_present count: 1
      end

      select_attic_box box_1

      within '.grouped-attachments' do
        file_previews_present count: 1
      end
    end

    scenario 'successfully moved files from attic box to top of the attic' do
      select_attic_box box_2

      within '.grouped-attachments' do
        file_previews_present count: 1
      end

      find('#move-button').click

      within file_group_selector(position: 1) do
        click_on_file position: 1
      end

      find('#move-button').click

      within '#move_files_to_box_modal' do
        find('.attic-list-item:nth-child(1)').click
        find('#move-to-box').click
      end

      expect(page).to have_text 'File(s) moved successfully'

      file_previews_present count: 0

      find('.attic-breadcrumbs__attic-name').click

      within '.grouped-attachments' do
        file_previews_present count: 3
      end
    end
  end
end
