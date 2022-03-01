require 'spec_helper'

describe Families::OwnershipService do
  subject(:result) { described_class.call(ownership_transfer) }

  let(:old_admin) { create :user }
  let(:new_admin) { create :user }
  let!(:family) { create :family, users: [old_admin, new_admin] }
  let!(:ownership_transfer) do
    create :ownership_transfer, new_admin: new_admin.reload, old_admin: old_admin.reload, family: family
  end

  it 'transfers family ownership from admin to member' do
    stub_mandrill
    expect { result }.to change { family.reload.admin }
      .from(old_admin)
      .to(new_admin)
      .and change { old_admin.reload.role_for(family) }
      .from('admin')
      .to('member')
      .and change { new_admin.reload.role_for(family) }
      .from('member')
      .to('admin')
      .and change(ownership_transfer, :status)
      .from('pending')
      .to('accepted')
  end

  context 'new admin deleted' do
    before do
      new_admin.destroy
      family.reload
    end

    it 'do nothing' do
      expect { result }.to avoid_changing(family, :admin)
        .and avoid_changing(ownership_transfer, :status)
    end
  end

  context 'new admin is no longer family member' do
    before do
      family.kinship_for(new_admin).destroy
      family.reload
    end

    it 'do nothing' do
      expect { result }.to avoid_changing(family, :admin)
        .and avoid_changing(ownership_transfer, :status)
    end
  end

  context 'current admin already changed' do
    let(:other_member) { create :user }
    let!(:ownership_transfer) do
      create :ownership_transfer, new_admin: new_admin.reload, old_admin: old_admin.reload, family: family
    end

    before do
      old_admin.kinships.find_by(family: family).update!(role: 'member')
      create :kinship, user: other_member, family: family, role: 'admin'
    end

    it 'do nothing' do
      expect { result }.to avoid_changing(family, :admin)
        .and avoid_changing(ownership_transfer, :status)
    end
  end
end
