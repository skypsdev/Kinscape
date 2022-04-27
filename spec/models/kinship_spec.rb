require 'spec_helper'

describe Kinship, type: :model do
  context 'personal_not_changed' do
    let!(:kinship) { create(:kinship) }

    it do
      expect { kinship.update!(access_type: :personal) }
        .to raise_error(ActiveRecord::RecordInvalid, 'Validation failed: Access type - attribute change not allowed')
    end
  end
end
