require 'spec_helper'

describe PublicationFilter do
  subject(:result) do
    described_class.call(publications: publications, params: params, current_user: story.user, includes: includes)
  end

  let!(:user) { create :user }
  let!(:family) { create :family, users: [user] }
  let!(:family2) { create :family, users: [user] }
  let!(:story) do
    create :story, user: user, title: 'Holidays 2019', category_list: ['white'], created_at: Time.current - 3.days
  end
  let!(:story2) do
    create :story, user: user, title: 'Holidays 2020', category_list: %w[red yellow], created_at: Time.current - 2.days
  end
  let!(:story3) do
    create :story, user: user, title: 'Winter', category_list: %w[white yellow], created_at: Time.current - 1.day
  end
  let!(:story4) do
    create :story, user: user, title: 'Only private', category_list: %w[white yellow], created_at: Time.current - 1.day
  end
  let!(:private_publication) do
    create :publication, publish_on: nil,
                         notified_at: nil,
                         story: story4,
                         family: story4.user.private_family,
                         share_type: :private,
                         created_at: Time.current - 3.days
  end
  let!(:includes) { {} }
  let!(:private_with_another_publication) do
    create :publication, publish_on: nil,
                         notified_at: nil,
                         story: story,
                         family: story.user.private_family,
                         share_type: :private,
                         created_at: Time.current - 3.days
  end
  let!(:published) do
    publication = build(:publication, publish_on: 1.day.ago,
                                      notified_at: 1.day.ago,
                                      story: story,
                                      family: family2,
                                      kinship: family2.kinship_for(story.user),
                                      share_type: :shared,
                                      created_at: Time.current - 2.days)
    publication.save validate: false
    publication
  end
  let!(:ordinary_publication) do
    create :publication, publish_on: nil,
                         family: family,
                         story: story2,
                         notified_at: 1.day.ago
  end
  let!(:scheduled) do
    create :publication, publish_on: 1.day.from_now,
                         story: story3,
                         family: family,
                         notified_at: nil
  end
  let!(:publications) do
    Publication.where(id: [private_publication,
                           private_with_another_publication,
                           published,
                           ordinary_publication,
                           scheduled])
  end

  context 'without any params' do
    let(:params) { {} }

    it do
      expect(result.count).to eq(3)
    end
  end

  context 'with family_id' do
    let(:params) { { family_id: family2.id } }

    it do
      expect(result.count).to eq(1)
    end
  end

  context 'with publication_visibility' do
    let(:params) { { publication_visibility: 'private_stories' } }

    it do
      expect(result).to contain_exactly(private_publication)
    end
  end

  context 'with multiple categories' do
    let(:params) { { categories: %w[white yellow] } }

    it do
      expect(result.count).to eq(1)
    end
  end

  context 'with single category' do
    let(:params) { { categories: %w[yellow] } }

    it do
      expect(result.count).to eq(2)
    end
  end

  context 'with author_id' do
    let(:params) { { author_id: story.user_id } }

    it do
      expect(result.count).to eq(3)
    end
  end

  context 'with query' do
    let(:params) { { query: 'holiday' } }

    it do
      expect(result.count).to eq(2)
    end
  end

  context 'with sort' do
    let(:params) { { sort_by: 'created_at', sort_direction: 'ASC' } }

    it do
      expect(result).to match_array([published, ordinary_publication, scheduled])
    end
  end

  context 'with all combined' do
    let(:params) do
      {
        family_id: published.family_id,
        publication_visibility: 'shared_stories',
        categories: published.story.category_list,
        author_id: published.story.user_id,
        query: 'holiday'
      }
    end

    it do
      expect(result.count).to eq(1)
    end
  end
end
