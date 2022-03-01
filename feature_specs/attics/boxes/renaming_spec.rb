require 'spec_helper'

feature 'Attic boxes: renaming', :js do
  include AtticsPageHelpers

  let!(:connector) { create :user }
  let!(:member) { create :user }
  let!(:box) { create :box, attic: attic, name: 'Empty box' }
  let!(:family) do
    create :family, connector: connector, users: [connector, member]
  end

  background do
    visit attic_path attic, as: current_user
  end

  shared_examples 'rename attic boxes flow' do
    scenario 'successfully renames attic box' do
      within attic_box_selector(position: 1) do
        find('.js-attic-box-name').set('Named Box').native.send_keys :tab
      end

      expect_saved_status

      visit attic_path attic

      # sleep 0.1 # Necessary or 'Named Box' is truncated. Find better way!

      within attic_box_selector(position: 1) do
        expect(page).to have_field(type: 'textarea', with: 'Named Box')
      end
    end

    scenario 'tries to rename already deleted box' do
      box.destroy

      within attic_box_selector(position: 1) do
        find('.js-attic-box-name').set('Named Box').native.send_keys :tab
      end

      expect(page).to have_text 'Sorry, this action can not be performed.'
    end
  end

  context 'connector within private attic' do
    let(:current_user) { connector }
    let(:attic) { connector.private_attic }

    it_behaves_like 'rename attic boxes flow'
  end

  context 'connector within family attic' do
    let(:current_user) { connector }
    let(:attic) { create :attic, family: family, user: connector }

    it_behaves_like 'rename attic boxes flow'
  end

  context 'family member within private attic' do
    let(:current_user) { member }
    let(:attic) { member.private_attic }

    it_behaves_like 'rename attic boxes flow'
  end

  context 'family member within family attic' do
    let(:current_user) { member }
    let(:attic) { create :attic, family: family, user: connector }

    scenario 'can not rename an attic box' do
      within attic_box_selector(position: 1) do
        expect(page).not_to have_css('textarea')
      end
    end
  end
end
