require 'spec_helper'

describe Families::CreationService do
  let!(:user) { create :user }

  describe '.create' do
    subject(:family) { described_class.call(user, params) }

    context 'with valid params' do
      let(:params) { { name: 'Purrkins', family_type: 'quite normal', motto: 'winter is coming' } }

      it 'creates family' do
        expect { family }.to change(Family, :count)
          .by(1)
          .and change(Vault, :count)
          .by(1)
          .and change(Box, :count)
          .by(1)
        expect(family).to have_attributes(params)
        expect(user.role_for(family)).to eq('admin')
      end
    end

    context 'with invalid name' do
      let(:params) { { name: '', family_type: 'quite normal' } }

      it 'does nothing' do
        expect { family }.to avoid_changing(Family, :count)
          .and avoid_changing(Vault, :count)
      end
    end

    context 'with invalid family_type' do
      let(:params) { { name: 'Purrkins', family_type: '' } }

      it 'does nothing' do
        expect { family }.to avoid_changing(Family, :count)
          .and avoid_changing(Vault, :count)
      end
    end
  end
end
