require 'spec_helper'

describe KinshipSerializer do
  # it_behaves_like 'stop_leaking_foreign_key', :kinship, :family
  it_behaves_like 'stop_leaking_foreign_key', :kinship, :family, :relation
end
