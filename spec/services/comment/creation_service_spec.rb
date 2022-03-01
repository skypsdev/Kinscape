require 'spec_helper'

describe Comment::CreationService do
  subject(:comment_result) { described_class.call(current_user, publication, params) }

  let!(:current_user) { create :user, email: 'current_user@email.com' }
  let!(:author) { create :user, email: 'author@email.com' }
  let(:family) { create :family, users: [current_user, author, previous_commenter] }
  let!(:story) { create :story, user: author }
  let!(:section) { create :section, story: story }
  let!(:old_family_member) { create :user, email: 'old_member@email.com' }
  let!(:previous_commenter) { create :user, email: 'previous_commenter@email.com' }
  let!(:publication) { create :publication, story: story, family: family }

  before { stub_mandrill }

  context 'with wrong type' do
    let(:params) { { body: 'Hello', commentable_type: 'Story', commentable_id: 1 } }

    it 'returns error' do
      expect(comment_result.errors.full_messages).to include('Commentable type is not included in the list')
    end
  end

  context 'with Publication commentable type' do
    let(:params) { { body: 'Hello', commentable_type: 'Publication', commentable_id: publication.id } }

    it 'sends emails to the author' do
      expect(comment_result.class).to eq(Comment)
      expect(comment_result).to be_persisted
      expect(emailed_addresses).to contain_exactly(author.email)
      expect(emailed_addresses).not_to include(old_family_member.email, current_user.email)
      expect(last_email_sent).to have_subject("#{current_user.name} has commented on your publication")
    end

    context 'with another comment present' do
      before do
        create :comment, commentable: publication, user: previous_commenter, body: 'previous comment'
        create :comment, commentable: publication, user: old_family_member, body: 'comment by old member'
      end

      it 'sends emails to the author and previous commenters' do
        expect(comment_result.class).to eq(Comment)
        expect(comment_result).to be_persisted
        expect(emailed_addresses).to contain_exactly(author.email, previous_commenter.email)
        expect(emailed_addresses).not_to include(old_family_member.email, current_user.email)
        expect(last_email_sent).to have_subject("#{current_user.name} has commented on your publication")
      end
    end
  end

  context 'with Section commentable type' do
    let(:params) { { body: 'Hello', commentable_type: 'Section', commentable_id: section.id } }

    it 'sends emails to the author and previous commenters' do
      expect(comment_result.class).to eq(Comment)
      expect(comment_result).to be_persisted
      expect(emailed_addresses).to contain_exactly(author.email)
      expect(emailed_addresses).not_to include(old_family_member.email, current_user.email)
      expect(last_email_sent).to have_subject("#{current_user.name} has commented on your section")
    end
  end

  context 'with Comment commentable type' do
    let!(:top_comment) { create :comment, commentable: publication, user: previous_commenter, body: 'comment' }
    let(:params) { { body: 'Hello', commentable_type: 'Comment', commentable_id: top_comment.uid } }

    it 'sends emails to the author and previous commenters' do
      expect(comment_result.class).to eq(Comment)
      expect(comment_result).to be_persisted
      expect(emailed_addresses).to contain_exactly(top_comment.user.email)
      expect(emailed_addresses).not_to include(old_family_member.email, current_user.email, author.email)
      expect(last_email_sent).to have_subject("#{current_user.name} has commented on your comment")
    end
  end
end
