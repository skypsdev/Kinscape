module SerializationHelper
  def current_user_serialize(user, params = {})
    return nil unless user

    UserSerializer.new(
      user,
      {
        params: { abilities: true, showcase: params[:showcase].present? },
        fields: { user: UserSerializer.attributes_to_serialize.keys }
      }
    ).to_json
  end
end
