# == Schema Information
#
# Table name: chapters
#
#  id               :bigint           not null, primary key
#  chapterable_id   :integer
#  chapterable_type :string
#  position         :integer
#  title            :string
#  body             :text
#  media_type       :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require 'spec_helper'

RSpec.describe Chapter, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:chapterable) }
    it { is_expected.to have_many(:media_files) }
  end

  # Chapterable as family object
  describe '#other_chapters_for_family' do
    it 'returns other chapters in family' do
      family = build(:family)
      chapter_f_1 = build(:chapter_family, chapterable: family)
      chapter_f_2 = build(:chapter_family, chapterable: family)
      chapter_f_3 = build(:chapter_family, chapterable: family)
      family.chapters = [chapter_f_1, chapter_f_2, chapter_f_3]

      expect(family.chapters).to eq [chapter_f_1, chapter_f_2, chapter_f_3]
    end
  end

  describe '#other_chapters_for_kinship' do
    it 'returns other chapters in kinship' do
      family = build(:family)
      user = build(:user)
      kinship = build(:kinship, user: user, family: family)

      chapter_k_1 = build(:chapter_kinship, chapterable: kinship)
      chapter_k_2 = build(:chapter_kinship, chapterable: kinship)
      chapter_k_3 = build(:chapter_kinship, chapterable: kinship)
      kinship.chapters = [chapter_k_1, chapter_k_2, chapter_k_3]

      expect(kinship.chapters).to eq [chapter_k_1, chapter_k_2, chapter_k_3]
    end
  end
end
