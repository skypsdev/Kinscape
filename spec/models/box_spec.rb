require 'spec_helper'

RSpec.describe Box, type: :model do
  subject { described_class.new }

  it { is_expected.to respond_to(:name) }
end
