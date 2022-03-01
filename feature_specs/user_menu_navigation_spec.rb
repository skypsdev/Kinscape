require 'spec_helper'

feature 'User menu navigation', :js do
  let!(:user) { create :user, first_name: 'Jake', last_name: 'Smith' }

  background do
    create :family, connector: user, users: [user]
  end

  context 'desktop' do
    background do
      visit stories_path(as: user)

      within 'header' do
        find('.user-menu-toggle').click
      end
    end

    scenario 'shows dropdown menu' do
      within 'header .header-nav-dropdown.open' do
        expect(page).to have_link(
          'Help',
          href: Global.app.external_links.help
        )
        expect(page).not_to \
          have_css('a.open-request-story-modal', text: 'Send a Message')
        expect(page).to have_link('Sign Out', href: sign_out_path)
      end
    end

    scenario "'Message' should be in top not side nav" do
      within 'header .header-nav-dropdown.open' do
        expect(page).not_to \
          have_css('a.open-request-story-modal', text: 'Message')
      end

      within '.global-header' do
        click_on 'Message'
      end

      expect(page).to have_text 'Send A Message To Members'
      expect(page).to have_button 'Send message', disabled: true
    end
  end

  context 'mobile', screen: :medium do
    scenario 'shows menu items' do
      visit stories_path(as: user)

      within 'header' do
        find('.user-menu-toggle').click
      end

      within 'nav#slide-menu' do
        expect(page).not_to \
          have_css('a.open-request-story-modal', text: 'Send a Message')
        expect(page).to have_link('Start a Story')
        expect(page).to have_link('Storyscape', href: stories_path)
        expect(page).to have_link('Familyscape', href: families_path)
        expect(page).to have_link('My Life', href: mylife_profile_path)
        expect(page).to have_link('Attic', href: attics_path)
        expect(page).to \
          have_css('a.open-request-story-modal', text: 'Message')
        expect(page).to have_link('Edit Profile', href: mylife_profile_path)
        expect(page).to have_link(
          'Help',
          href: Global.app.external_links.help
        )
        expect(page).not_to have_link('Account', href: account_path)
        expect(page).to have_link('Sign Out', href: sign_out_path)
      end
    end

    scenario "click on 'Message' opens proper popup" do
      visit stories_path(as: user)

      within 'header' do
        find('.user-menu-toggle').click
      end

      within 'nav#slide-menu' do
        click_on 'Message'
      end

      within '.request-story-modal' do
        expect(page).to have_css('h2', text: 'Send A Message')
      end
    end

    # Temp. remove payment feature
    # context 'for guest' do
    #   background do
    #     create :subscription, user: user, status: 'past_due'

    #     visit stories_path(as: user)

    #     within 'header' do
    #       find('.user-menu-toggle').click
    #     end
    #   end

    #   scenario 'does not show start story and message' do
    #     within 'nav#slide-menu' do
    #       expect(page).not_to have_link('Start a Story')
    #       expect(page).not_to \
    #         have_css('a.open-request-story-modal', text: 'Message')
    #     end
    #   end
    # end
  end
end
