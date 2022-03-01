# require 'spec_helper'

# feature 'Insert attachment from attic', :js do
#   include AtticsPageHelpers
#   include StoriesPageHelpers

#   let!(:user)    { create :user }
#   let!(:family)  { create :family, users: [user], name: 'Smith' }
#   let!(:attic)   { create :attic, family: family, user: user }
#   let!(:story)   { create :story, user: user, families: [family] }
#   let!(:section) { create :text_section, story: story, author: user }

#   background do
#     attic.attachments << [attachment_1, attachment_2].compact

#     visit stories_path(as: user)
#     dismiss_cookieconsent

#     find('.story', text: story.title).hover

#     click_on 'edit'

#     open_attic_modal
#   end

#   context 'when no files in the attic' do
#     let(:attachment_1) { nil }
#     let(:attachment_2) { nil }
#     let(:box) { nil }

#     scenario 'user sees message about absent attachments in the attic' do
#       find('.title-text', text: 'Smith Family Attic').click

#       expect(page).to have_text 'No files uploaded to selected Attic or Box'
#     end
#   end

#   context 'when video attachments' do
#     let(:video_1) { create :video_media_file }
#     let(:video_2) { create :video_media_file }

#     let(:attachment_1) do
#       create :attachment,
#              media_file: video_1,
#              created_at: Time.parse('2014-01-10')
#     end

#     let(:attachment_2) do
#       create :attachment,
#              media_file: video_2,
#              created_at: Time.parse('2014-02-10')
#     end

#     scenario 'user inserts multiple video files at a time' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         within file_group_selector(position: 2) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       expect(page).to have_css('.attachment--content', count: 2)
#     end
#   end

#   context 'when audio attachments' do
#     let(:audio_1) { create :audio_media_file }
#     let(:audio_2) { create :audio_media_file }

#     let(:attachment_1) do
#       create :attachment,
#              media_file: audio_1,
#              created_at: Time.parse('2014-01-10')
#     end

#     let(:attachment_2) do
#       create :attachment,
#              media_file: audio_2,
#              created_at: Time.parse('2014-02-10')
#     end

#     scenario 'user inserts multiple audio files at a time' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         within file_group_selector(position: 2) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       expect(page).to have_css('.attachment--content', count: 2)
#     end
#   end

#   context 'when document attachments' do
#     let(:document_1) { create :document_media_file, filename: 'File one' }
#     let(:document_2) { create :document_media_file, filename: 'File two' }

#     let(:attachment_1) do
#       create :attachment,
#              media_file: document_1,
#              created_at: Time.parse('2014-01-10')
#     end

#     let(:attachment_2) do
#       create :attachment,
#              media_file: document_2,
#              created_at: Time.parse('2014-02-10')
#     end

#     scenario 'user inserts multiple documents at a time' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         within file_group_selector(position: 2) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       expect(page).to have_text('File one')
#       expect(page).to have_text('File two')
#       expect(page).to have_css('.attachment--content', count: 2)
#     end
#   end

#   context 'when photo attachments' do
#     let(:attachment_1) do
#       create :attachment,
#              created_at: Time.parse('2014-01-10')
#     end
#     let(:attachment_2) do
#       create :attachment,
#              created_at: Time.parse('2014-02-10')
#     end

#     scenario 'user open dialog window with attics list' do
#       within '.attics-list' do
#         expect(page).to have_css 'li:nth-child(1)', text: 'My Attic'
#         expect(page).to have_css 'li:nth-child(2)', text: 'Smith Family Attic'
#       end
#     end

#     scenario 'user select attachment inside attic' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#           selected_file_present position: 1
#         end
#       end
#     end

#     scenario 'user insert single attachment into story' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       photoset_present images_count: 1
#     end

#     scenario 'user insert multiple attachments into story' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         within file_group_selector(position: 2) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       photoset_present images_count: 2
#     end

#     scenario 'selected files are deselected after insertion' do
#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         within file_group_selector(position: 1) do
#           click_on_file position: 1
#         end

#         click_on 'Insert'
#       end

#       photoset_present images_count: 1

#       open_attic_modal

#       within '.attic-modal' do
#         find('.title-text', text: 'Smith Family Attic').click

#         no_attachments_selected
#       end
#     end
#   end

#   context 'when photo attachments within attic boxes' do
#     let(:box) { create :box, attic: attic, name: 'Box for stories' }

#     let(:attachment_1) do
#       create :attachment,
#              created_at: Time.parse('2014-01-10')
#     end
#     let(:attachment_2) do
#       create :attachment,
#              created_at: '2014-02-10', box: box
#     end
#   end
# end
