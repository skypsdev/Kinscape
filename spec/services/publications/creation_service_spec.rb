require 'spec_helper'

describe Publications::CreationService do
  subject(:result) { described_class.call(story, user, params) }

  let(:user) { create :user }
  let(:another_user) { create :user }
  let!(:family) { create :family, users: [user, another_user] }
  let!(:story) { create(:story, user: user, category_list: ['summer', "90's"]) }
  let(:params) do
    {
      families_ids: families_ids,
      publish_on: publish_on,
      share_type: share_type
    }
  end
  let(:publish_on) { { year: '3030', month: 'June', day: '1' } }
  let(:share_type) { 'shared' }
  let(:families_ids) { [family.id] }

  context 'with guest role in family' do
    before do
      user.kinships.find_by(family: family).update!(role: :guest)
    end

    it 'does not create a publication' do
      expect { result }.to avoid_changing(Publication, :count)
        .and avoid_changing(Story, :count)
    end
  end

  context 'with shared type' do
    it 'creates a publication without new story' do
      expect { result }.to change(Publication, :count)
        .by(2)
        .and change(Story, :count)
        .by(1)
      expect(story.publications.first).to be_present
      publication = result.last
      expect(publication.share_type).to eq('shared')
      expect(publication.kinship.user).to eq(user)
    end
  end

  context 'with community share type' do
    let(:share_type) { 'community' }

    it 'creates a publication without new story' do
      expect { result }.to change(Publication, :count)
        .by(1)
        .and change(Story, :count)
        .by(1)
      expect(story.shared_stories).to be_present
      new_story = story.shared_stories.first
      expect(new_story.publications.first.share_type).to eq('community')
      expect(new_story.publications.count).to eq(1)
      expect(new_story.category_list).to eq(story.category_list)
      expect(new_story).to have_attributes(
        story.attributes.except('id', 'created_at', 'updated_at',
                                'cover_image_id', 'original_story_id', 'title', 'category_list')
      )
    end
  end

  context 'with many families' do
    let!(:family2) { create :family, users: [user, another_user] }
    let(:families_ids) { [family.id, family2.id] }

    it 'creates a publication without new story' do
      expect { result }.to change(Publication, :count)
        .by(3)
        .and change(Story, :count)
        .by(1)
      expect(story.publications.first).to be_present
    end

    context 'with personal stories' do
      let(:share_type) { 'community' }
      let(:families_ids) { [family.id, family2.id, user.personal_family.id] }

      it 'creates a publication without new story' do
        expect { result }.to change(Publication, :count)
          .by(3)
          .and change(Story, :count)
          .by(2) # 1 shared type in personal family
        expect(story.publications.first).to be_present
      end
    end
  end

  context 'when `publish on` is in the past' do
    let(:publish_on) { { year: '1030', month: 'June', day: '1' } }

    it 'does not create a publication' do
      expect(result.errors.full_messages).to eq(['Time Capsule release date must be in future'])
      expect(story.publications.not_private_type.count).to eq(0)
    end
  end

  context 'when `publish on` is invalid' do
    let(:publish_on) { { year: '3030', month: 'Gune', day: '-1' } }

    it 'does not create a publication' do
      expect { result }.to raise_error(Date::Error)
      expect(story.publications.not_private_type.count).to eq(0)
    end
  end

  context 'when `publish on` is missing' do
    let(:publish_on) { nil }

    it 'creates a publication with the blank `publish_on`' do
      stub_mandrill
      result
      expect(story.reload.publications.first).to be_present
      expect(story.publications.first.publish_on).to be_nil
      expect(emailed_addresses).to match_array([another_user.email])
      expect(last_email_sent).to have_subject(I18n.t('mailer.story_published.community_story', user_name: user.name))
    end
  end
end
