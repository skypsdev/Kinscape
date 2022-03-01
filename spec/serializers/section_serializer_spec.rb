require 'spec_helper'

describe SectionSerializer do
  it_behaves_like 'stop_leaking_foreign_key', :section, :story
end
