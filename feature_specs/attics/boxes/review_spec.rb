require 'spec_helper'

feature 'Reviewing', :js do
  include AtticsPageHelpers

  let!(:user)      { create :user }
  let!(:empty_box) { create :box, name: 'Empty Box', attic: user.private_attic }
  let!(:toolbox)   { create :box, name: 'Toolbox', attic: user.private_attic }
  let!(:books_box) { create :box, name: 'Books', attic: user.private_attic }

  let(:hammer)    { create :attachment, box: toolbox }
  let(:handsaw)   { create :attachment, box: toolbox }
  let(:sandpaper) { create :attachment, box: toolbox }
  let(:manual)    { create :attachment, box: books_box }
  let(:cookbook)  { create :attachment, box: books_box }
  let(:marker)    { create :attachment }

  background do
    user.private_attic.attachments << [
      marker,
      hammer,
      handsaw,
      sandpaper,
      manual,
      cookbook
    ]
    visit attic_path user.private_attic, as: user
  end

  scenario 'User selects no box' do
    within '.grouped-attachments' do
      file_previews_present count: 1
    end
  end

  scenario 'User selects an empty box' do
    select_attic_box empty_box
    expect(page).not_to have_css('attachment')
  end

  scenario 'User selects a full box' do
    select_attic_box toolbox

    within '.grouped-attachments' do
      file_previews_present count: 3
    end
  end

  scenario 'User gets back from a box' do
    select_attic_box empty_box

    find('.attic-breadcrumbs__attic-name').click

    within '.grouped-attachments' do
      file_previews_present count: 1
    end
  end

  scenario 'does not show "Add box" button within attic box' do
    within '.submenu' do
      expect(page).to have_button 'Add Box'
    end

    select_attic_box empty_box

    within '.submenu' do
      expect(page).to have_no_button 'Add Box'
    end
  end
end
