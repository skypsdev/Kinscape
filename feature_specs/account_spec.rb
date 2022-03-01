require 'spec_helper'

feature 'Connector account', :js, with_csrf_protection: true do
  let(:connector) { create :user }
  let(:family_member) { create :user }

  before do
    @family = create(
      :family,
      connector: connector,
      users: [connector, family_member]
    )
  end

  context 'as a family member' do
    scenario 'user does not see a Change Connector action' do
      visit account_path as: family_member

      expect(page).not_to have_link 'Change Connector'
    end

    scenario 'user sees a Download My Content action' do
      visit account_path as: connector

      expect(page).to have_link 'Download My Content'
    end

    scenario 'user can remove the family' do
      visit account_path as: family_member
      dismiss_cookieconsent

      find('.account__family-title').hover
      find('#list-for-account').find('.account__family .remove-family').click

      find('.confirmation-dialog.remove-family').find('button.ok').click
      find('.confirmation-dialog.warning-family').find('button.ok').click

      expect(page).not_to have_link @family.name
    end

    scenario 'can update his user information' do
      visit account_path as: family_member
      fill_in 'user_first_name', with: 'Firstnamerson'
      fill_in 'user_last_name', with: 'Connors'
      fill_in 'user_email', with: 'firstnamerson@connors.com'

      click_on 'Update user information'

      expect(page).to have_current_path(account_path)
      expect(page).to have_field('First Name', with: 'Firstnamerson')
      expect(page).to have_field('Last Name', with: 'Connors')
      expect(page).to have_field('Email', with: 'firstnamerson@connors.com')
    end

    scenario 'checks for password confirmation' do
      visit account_path as: family_member
      fill_in 'user_password', with: '1111'

      click_on 'Update user information'

      expect(flash).to have_text 'There is an error in the form'

      fill_in 'user_password',              with: '1111'
      fill_in 'user_password_confirmation', with: '1111'

      click_on 'Update user information'

      expect(page).to have_current_path(account_path)
    end
  end

  context 'as a family connector' do
    scenario 'user sees a Change Connector action' do
      visit account_path as: connector

      expect(page).to have_link 'Change Connector'
    end

    scenario 'user sees a Download My Content action' do
      visit account_path as: connector

      expect(page).to have_link 'Download My Content'
    end
  end

  context 'user can remove the account' do
    let(:user) { create :user }

    before do
      @family = create(
        :family,
        connector: user
      )

      @attic = create(
        :attic,
        user: user,
        family: @family
      )

      @story = create(
        :story,
        user: user
      )

      # @subscription = create(
      #   :subscription,
      #   user: user
      # )

      @comment = create(
        :comment,
        user: user
      )

      visit account_path as: user

      find('.account-control').find('.remove-account').click
      find('.confirmation-dialog.remove-account').find('button.ok').click
      find('.confirmation-dialog.warning-account').find('button.ok').click

      Timeout.timeout(Capybara.default_max_wait_time) do
        loop until current_path == '/'
      end
    end

    scenario 'user can remove everything' do
      expect(Family.find_by(id: @family.id)).to be_nil
      expect(Attic.find_by(id: @attic.id)).to be_nil
      expect(Story.find_by(id: @story.id)).to be_nil
      # expect(Subscription.find_by(id: @subscription.id)).to be_nil
      expect(Comment.find_by(id: @comment.id)).to be_nil
      expect(User.find_by(id: user.id)).to be_nil
    end

    scenario 'user redirected to the home page' do
      expect(current_path).to eq '/'
    end
  end
end
