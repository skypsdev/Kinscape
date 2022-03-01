require 'spec_helper'

describe PublicationSerializer do
  it_behaves_like 'stop_leaking_foreign_key', :publication, :family, :relation
  it_behaves_like 'stop_leaking_foreign_key', :publication, :story, :relation
end
