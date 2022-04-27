When(/^I create a new community$/) do
  click_link 'Communities'
  # TODO: The below 'within' should be easily selectable without using vue framework selectors
  within '.v-toolbar__content' do
    click_button 'Create Community'
  end

  # TODO: The below need to be more easily selectable, id or name
  fill_in 'Give your Community a name.', with: 'Gandalf appreciation society'
  # TODO: The below need to be more easily selectable, id or name
  fill_in 'Add a motto or slogan.', with: 'You shall not pass!'

  # TODO: currently no way to select and fill in description, this needs to be fixed
  # fill_in 'xxxxxxx', with: 'Lets share our fondest memories of times spent with Gandalf.'

  # TODO: The below need to be more easily selectable, id if possible
  find('div.v-card__actions > button').click
  # click_button # 'Create Community'
end

When(/^I add my first chapter to the community$/) do
  sleep 1 # TODO
  visit current_path # TODO: header need to be reloaded to have edit button / add chapter button
  # click_button 'Add Chapter'
  find('div.table-of-contents > div > button').click
  sleep 1 # TODO
  content_editor = find('trix-editor.trix-content')
  content_editor.set("Some content for my first chapter")
  fill_in 'Untitled Chapter', with: 'My first chapter'

  sleep 1 # << anti-pattern, but all I can do to get working at the moment
  # TODO: Figure out a way to not have to use sleep to give enough save time
  click_link 'Save'
end

Then(/^it should appear in my communities list$/) do
  visit '/communities'

  expect(page).to have_content 'Gandalf appreciation society'
end

Then(/^I should be able to view my new community$/) do
  click_link 'Gandalf appreciation society'

  expect(page).to have_content 'Gandalf appreciation society'
  expect(page).to have_content 'You shall not pass!'
  expect(page).to have_content 'My first chapter'
  expect(page).to have_content 'Some content for my first chapter'
end
