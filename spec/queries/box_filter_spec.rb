require 'spec_helper'

describe BoxFilter do
  subject(:result) do
    described_class.call(params: params)
  end

  let(:user) { create :user }
  let(:vault_id) { user.vault.id }
  let!(:box1) { create :box, vault: user.vault, name: 'Summer 2021' }
  let!(:box2) { create :box, vault: user.vault, name: 'Summer 2020' }
  let!(:box3) { create :box, vault: user.vault, name: 'Last Winter' }
  let!(:child_box) { create :box, vault: user.vault, name: 'Child', parent_box_id: box1.id }

  context 'without any params' do
    let(:params) { { id: vault_id } }

    it do
      expect(result.count).to eq(3)
    end
  end

  context 'with query' do
    let(:params) { { id: vault_id, query: 'summer' } }

    it do
      expect(result.count).to eq(2)
    end
  end

  context 'with sort' do
    let(:params) { { id: vault_id, sort_by: 'name', sort_direction: 'ASC' } }

    it do
      expect(result).to match_array([box3, box1, box2])
    end
  end

  context 'with box id' do
    let(:params) { { id: vault_id, box_id: box1.id } }

    it do
      expect(result.count).to eq(1)
      expect(result.first['id']).to eq(child_box.id)
    end
  end

  context 'with all combined' do
    let(:params) do
      {
        id: vault_id,
        sort_by: 'name',
        sort_direction: 'ASC',
        query: 'summer'
      }
    end

    it do
      expect(result.count).to eq(2)
    end
  end
end
