require 'spec_helper'

feature 'Attic boxes: creation', :js do
  include AtticsPageHelpers

  let!(:family) { create :family }
  let!(:connector) { create :user, families: [family] }
  let!(:member) { create :user, families: [family] }

  background do
    visit attic_path attic, as: current_user
    dismiss_cookieconsent
  end

  context 'within private attic' do
    let(:current_user) { connector }
    let(:attic) { connector.private_attic }

    scenario 'create new attic box' do
      within '.attic-submenu' do
        click_on 'Add Box'
      end

      within attic_box_selector(position: 1) do
        # expect(find('textarea').value).to eq 'Untitled box'
        expect(page).to have_field(type: 'textarea', with: 'Untitled box')
      end
    end
  end

  context 'family connector within family attic' do
    let(:attic) { create :attic, family: family, user: connector }
    let(:current_user) { connector }

    scenario 'create new attic box' do
      within '.attic-submenu' do
        click_on 'Add Box'
      end

      within attic_box_selector(position: 1) do
        # expect(find('textarea').value).to eq 'Untitled box'
        expect(page).to have_field(type: 'textarea', with: 'Untitled box')
      end
    end
  end

  context 'family member within family attic' do
    let(:attic) { create :attic, family: family, user: connector }
    let(:current_user) { member }

    scenario 'create new attic box' do
      within '.attic-submenu' do
        expect(page).to have_text 'Add Box'
      end
    end
  end
end
