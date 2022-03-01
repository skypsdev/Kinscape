require 'spec_helper'

RSpec.describe PagesController, type: :controller do
  describe "GET 'privacy'" do
    it 'returns http success' do
      get :show, params: { id: :privacy }
      expect(response).to be_successful
    end
  end

  describe "GET 'terms_of_use'" do
    it 'returns http success' do
      get :show, params: { id: :terms_of_use }
      expect(response).to be_successful
    end
  end
end
