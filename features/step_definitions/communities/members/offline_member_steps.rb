
#create

When(/^I create a new offline member$/) do
  visit '/communities'
  click_link 'Gandalf appreciation society'
  click_link 'Members'
  click_button 'Add Offline Member'
  fill_in 'Type name here', with: 'Offline Frodo'
  click_button 'Create Profile'
end

Then(/^it should appear in my community members list$/) do
  visit '/communities'
  click_link 'Gandalf appreciation society'
  click_link 'Members'

  expect(page).to have_content 'Offline Frodo'
end

#edit

When(/^I edit the details of the offline member$/) do
  visit '/communities'
  click_link 'Gandalf appreciation society'
  click_link 'Members'
  click_member_tile("Offline Frodo")
  sleep(1)
  click_link 'Edit'
  within '.profile-edit__input' do
    find('input').set('Offline Samuel', clear: :backspace )
  end
  click_link 'Save'
end

Then(/^those updates should be seen on the member page$/) do
  expect(page).to have_content 'Offline Samuel'
end





