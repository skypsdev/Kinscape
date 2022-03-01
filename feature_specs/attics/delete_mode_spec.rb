require 'spec_helper'

feature 'Delete mode', :js do
  include AtticsPageHelpers

  let!(:family)        { create :family }

  let!(:connector)     { create :user, families: [family] }
  let!(:family_member) { create :user, families: [family] }

  let!(:family_attic)  { create :attic, family: family, user: connector }

  context 'when no files in attic' do
    it 'hides "Delete" button' do
      visit attic_path family_attic, as: connector

      expect(page).not_to have_link 'Delete'
    end
  end

  context 'when there are files in the attic' do
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

    background do
      family_attic.attachments << [attachment_1, attachment_2, attachment_3]
    end

    context 'family member' do
      background do
        visit attic_path family_attic, as: family_member
      end

      scenario 'sees only files uploaded by him' do
        find('#delete-button').click

        expect(page).to have_no_css "#attachment_#{attachment_1.id}"
        expect(page).to have_no_css "#attachment_#{attachment_2.id}"
        expect(page).to have_css "#attachment_#{attachment_3.id}"
      end

      scenario 'tries to delete nothing' do
        find('#delete-button').click
        find('#delete-button').click

        expect(page).to have_text(/You must select file\(s\)/i)

        click_on 'OK'
      end

      scenario 'deletes own files from the Attic' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1
        end

        click_with_confirm('#delete-button')

        expect(page).to have_text 'File(s) deleted successfully'

        expect(page).to have_css "#attachment_#{attachment_1.id}"
        expect(page).to have_css "#attachment_#{attachment_2.id}"
        expect(page).to have_no_css "#attachment_#{attachment_3.id}"
      end

      scenario 'sees message when there are no files for deletion' do
        attachment_3.destroy

        visit attic_path family_attic, as: family_member

        find('#delete-button').click

        expect(page).to have_text 'You have no attachments that you can delete.'
      end
    end

    context 'family connector' do
      background do
        visit attic_path family_attic, as: connector
      end

      scenario 'delete files from the Attic' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1
        end

        click_with_confirm('#delete-button')

        expect(page).to have_text 'File(s) deleted successfully'

        expect(page).to have_no_css "#attachment_#{attachment_3.id}"
        expect(page).to have_css "#attachment_#{attachment_2.id}"
        expect(page).to have_css "#attachment_#{attachment_1.id}"
      end

      scenario 'cancel deletion of selected files' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1
        end

        find('#delete-button').click

        cancel_action

        expect(page).to have_css "#attachment_#{attachment_2.id}"
        expect(page).to have_css "#attachment_#{attachment_1.id}"
      end

      scenario 'switching to delete mode' do
        expect(page).to have_no_text 'Select files to delete'
        expect(page).to have_no_css '#cancel-button'

        find('#delete-button').click

        expect(page).to have_text 'Select files to delete'
        expect(page).to have_no_css '#delete-mode-button'
        expect(page).to have_css '#cancel-button'

        find('#cancel-button').click

        expect(page).to have_no_text 'Select files to delete'
        expect(page).to have_no_css '#cancel-button'
      end

      scenario 'selecting files to be deleted' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1
          selected_file_present position: 1
        end
      end

      scenario 'deselecting selected files' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1

          click_on_file position: 1

          no_attachments_selected
        end
      end

      scenario 'files are deselected when Delete mode is turned off' do
        find('#delete-button').click

        within file_group_selector(position: 1) do
          click_on_file position: 1
        end

        find('#cancel-button').click

        no_attachments_selected

        find('#delete-button').click

        no_attachments_selected
      end
    end
  end
end
