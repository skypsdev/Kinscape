require 'spec_helper'

feature 'User updating', :js do
  let(:family) { create(:family) }
  let(:user) { create(:kinship, family: family).user }
  let(:ward) { create(:user, caretaker: user) }

  scenario 'updates profile information' do
    visit mylife_profile_path(as: user)

    within '.my-life-submenu' do
      find('.back-link a').click
    end

    fill_in 'Nickname', with: 'jks'
    fill_in 'Birth Date', with: '1980-01-01'
    fill_in 'Location', with: 'Bay Area'
    fill_in 'Address', with: '1st Bay street, 999'
    fill_in 'Email', with: 'jake@smith.com'
    fill_in 'Birth Place', with: 'New York'
    fill_in 'Death Date', with: '2018-01-01'

    within '.my-life-submenu' do
      find('.back-link a').click
    end

    expect(page).to have_text 'jks'
    expect(page).to have_text 'Bay Area'
    expect(page).to have_text '1980-01-01'
    expect(page).to have_text '1st Bay street, 999'
    expect(page).to have_text 'jake@smith.com'
    expect(page).to have_text 'New York'
    expect(page).to have_text '2018-01-01'

    # Ensure values are persisted
    visit mylife_profile_path(as: user)
    expect(page).to have_text 'Bay Area'
    expect(page).to have_text '1980-01-01'
    expect(page).to have_text '1st Bay street, 999'
    expect(page).to have_text 'jake@smith.com'
    expect(page).to have_text 'New York'
    expect(page).to have_text '2018-01-01'
  end
end
