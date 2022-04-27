When(/^I navigate to the my life page$/) do
  click_link 'My Life'
end

When(/^I update my personal details$/) do
  fill_in 'Nickname', with: 'Nickey Namey'
  fill_in 'Email', with: 'my@email.com'
  fill_in 'Phone', with: '07123456789'
  fill_in 'Birth Place', with: 'London'
  fill_in 'Address', with: '123 Imaginary Way'
end

When(/^I add my first chapter to my profile$/) do

end

When(/^I already have a chapter$/) do

end

When(/^I add a new additional chapter to my profile$/) do

end

Then(/^my personal details should be visible to others$/) do
  expect(false).to be true
end

Then(/^my first chapter should be visible to others$/) do
  expect(false).to be true
end

Then(/^my additional chapter should be visible to others$/) do
  expect(false).to be true
end