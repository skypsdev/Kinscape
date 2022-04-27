When(/^I have created a community$/) do
  step 'I create a new community'
  step 'I add my first chapter to the community'
end

When(/^I edit the details of the community$/) do
  click_link 'Edit'

  # TODO: Unable to select community name or motto when editing, should be selectable, needs to be part of the test
  # find(:xpath, "//input[@type='text']").first.set('NEW COMMUNITY NAME')
  # find(:xpath, "//input[@type='text'").second.set('NEW MOTTO')
  # fill_in 'Community Name', with: 'NEW COMMUNITY NAME'
  # fill_in 'Motto', with: 'NEW MOTTO'

  # TODO: The below is not good, the textarea needs to be easily selectable.
  # Current selector is relying on the fact it is the only textarea within that div
  within '.community-description-edit' do
    find('textarea').set('NEW COMMUNITY DESCRIPTION')
  end
  sleep(1)

  click_link 'Save'
end

When(/^I edit an existing chapter in that community$/) do

end

Then(/^those updates should be seen on the community page$/) do
  expect(page).to have_content 'NEW COMMUNITY DESCRIPTION'
end