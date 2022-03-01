require 'spec_helper'

feature 'Reviewing', :js do
  include AtticsPageHelpers

  let!(:user)         { create :user }
  let!(:friend)       { create :user }
  let!(:family)       { create :family, name: 'Johns', users: [user, friend] }
  let!(:family_attic) { create :attic, family: family, user: user }

  context 'attics sub navigation dropdown' do
    context 'on private attic page' do
      background do
        visit attic_path(user.private_attic, as: user)

        within 'ul.submenu' do
          expect(page).to have_selector 'div.selected', text: 'My Attic'
          find('.attic-dropdown').click
        end
      end

      scenario 'user sees list of available attics, except the selected one' do
        within '.list' do
          expect(page).to have_selector('div', text: 'Johns Family Attic')
        end
      end
    end

    context 'on the family attic page' do
      background do
        visit attic_path(family_attic, as: user)

        within 'ul.submenu' do
          expect(page).to have_selector 'div.selected',
                                        text: 'Johns Family Attic'
          find('.attic-dropdown').click
        end
      end

      scenario 'user sees list of available attics, except the selected one' do
        within '.list' do
          expect(page).to have_selector('div', text: 'My Attic')
        end
      end
    end
  end

  context 'empty attic' do
    background do
      visit attic_path(family_attic, as: user)
    end

    scenario 'user sees a message that no media was uploaded' do
      expect(page).to have_text 'Add image, audio, video or other files'
    end
  end

  context 'attic with attachments' do
    let(:attachment_1) do
      create :attachment,
             created_at: Time.parse('2014-01-10')
    end
    let(:attachment_2) do
      create :attachment,
             created_at: Time.parse('2014-01-10')
    end
    let(:attachment_3) do
      create :attachment,
             created_at: Time.parse('2014-02-20')
    end
    let(:attachment_4) do
      create :attachment,
             created_at: Time.parse('2014-01-10')
    end
    let(:attachment_5) do
      create :attachment,
             created_at: Time.parse('2014-02-01')
    end
    let(:private_attachments) { [attachment_1, attachment_2, attachment_3] }
    let(:family_attachments)  { [attachment_4, attachment_5] }

    background do
      user.private_attic.attachments << private_attachments
      family_attic.attachments       << family_attachments
    end

    context 'private attic' do
      background do
        visit attics_path as: user

        click_on 'My Attic'
      end

      scenario 'user sees file groups ordered by upload dates DESC' do
        within file_group_selector(position: 1) do
          upload_date_present 'February 20, 2014'
          file_previews_present count: 1
        end

        within file_group_selector(position: 2) do
          upload_date_present 'January 10, 2014'
          file_previews_present count: 2
        end
      end
    end

    context 'family attic' do
      background do
        visit attics_path as: friend

        click_on 'Johns Family Attic'
      end

      scenario 'family member sees file groups ordered by upload dates DESC' do
        within file_group_selector(position: 1) do
          upload_date_present 'February 1, 2014'
          file_previews_present count: 1
        end

        within file_group_selector(position: 2) do
          upload_date_present 'January 10, 2014'
          file_previews_present count: 1
        end
      end
    end
  end
end
