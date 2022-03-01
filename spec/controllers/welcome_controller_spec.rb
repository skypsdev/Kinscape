require 'spec_helper'

describe WelcomeController, type: :controller do
  describe "GET 'index'" do
    it 'returns http success' do
      sign_in
      get :index
      expect(response).to be_successful
    end
  end
end
