require 'spec_helper'

shared_examples_for 'appreciable' do
  # let(:model) { create(described_class.to_s.underscore) }
  # let(:user)  { create :user }

  it { is_expected.to have_many(:appreciations) }
  it { is_expected.to have_db_column(:appreciations_count) }
end
