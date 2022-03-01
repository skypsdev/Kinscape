module Requests
  def sign_in_as(user)
    allow_any_instance_of(Api::V1::BaseController).to receive(:current_user).and_return(user)
  end
end
