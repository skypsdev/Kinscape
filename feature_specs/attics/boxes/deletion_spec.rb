require 'spec_helper'

feature 'Attic boxes: deletion', :js do
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

  shared_examples 'attic box deletion flow' do
    scenario 'successfully deletes attic box' do
      within attic_box_selector(position: 1) do
        click_delete
      end

      confirm_action

      expect(page).to have_text 'Box deleted successfully'
      expect(page).to have_no_text 'Empty box'
    end

    scenario 'refuses deletion' do
      within attic_box_selector(position: 1) do
        click_delete
      end

      cancel_action

      within attic_box_selector(position: 1) do
        expect(page).to have_field(type: 'textarea', with: 'Empty box')
      end
    end

    scenario 'tries to delete already deleted box' do
      box.destroy

      within attic_box_selector(position: 1) do
        click_delete
      end

      confirm_action

      expect(page).to have_text 'Sorry, this action can not be performed.'
    end
  end

  context 'connector within private attic' do
    let(:attic) { connector.private_attic }
    let(:current_user) { connector }

    it_behaves_like 'attic box deletion flow'
  end

  context 'family member within private attic' do
    let(:attic) { member.private_attic }
    let(:current_user) { member }

    it_behaves_like 'attic box deletion flow'
  end

  context 'connector within family attic' do
    let(:attic) { create :attic, family: family, user: connector }
    let(:current_user) { connector }

    it_behaves_like 'attic box deletion flow'
  end

  context 'family member within family attic' do
    let(:attic) { create :attic, family: family, user: connector }
    let(:current_user) { member }

    scenario 'can not delete box' do
      within attic_box_selector(position: 1) do
        expect(page).to have_no_css '.item-delete'
      end
    end
  end

  def click_delete
    find('.item-delete').click
  end
end
