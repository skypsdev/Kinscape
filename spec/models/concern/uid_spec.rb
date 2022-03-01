require 'spec_helper'

RSpec.describe Uid do
  context 'with find_by' do
    subject(:result) { Family.find_by_uid(uid) }

    let(:family) { create :family }
    let(:uid) { family.uid }

    it 'returns correct data' do
      expect(result).to eq(family)
    end

    context 'with invalid uid' do
      let(:uid) { 'some-invalid-uid' }

      it 'returns nil' do
        expect(result).to eq(nil)
      end
    end
  end

  context 'with find_by!' do
    subject(:result) { Family.find_by_uid!(uid) }

    let(:family) { create :family }
    let(:uid) { family.uid }

    it 'returns correct data' do
      expect(result).to eq(family)
    end

    context 'with invalid uid' do
      let(:uid) { 'some-invalid-uid' }

      it 'raise RecordNotFound error' do
        expect { result }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
