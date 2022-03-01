require 'spec_helper'

describe IntercomDataHelper, type: :helper do
  describe '#intercom_script_tag_for_current_user' do
    it 'returns nil in test environment' do
      expect(helper.intercom_script_tag_for_current_user).to be_nil
    end
  end
end
