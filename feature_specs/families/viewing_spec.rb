require 'spec_helper'

feature 'Families viewing', :js do
  include FamiliesPageHelpers
  include AtticsPageHelpers

  let!(:family) do
    create :family, name: 'Purrkins', motto: 'Faithful thought unfortunate'
  end

  let!(:connector)     { create :user, families: [family] }
  let!(:family_member) { create :user, families: [family] }
  let!(:kinship)       { family_member.kinships.first }

  context 'viewing family profile' do
    background do
      visit family_path(family, as: family_member)
    end

    scenario 'user see family information' do
      expect(page).to have_css 'h1', text: 'Purrkins'
      expect(page).to have_css 'p', text: 'Faithful thought unfortunate'
    end
  end
end
