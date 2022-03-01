module SerializationHelper
  def current_user_serialize(user)
    return nil unless user

    UserSerializer.new(
      user,
      {
        params: { abilities: true },
        fields: { user: UserSerializer.attributes_to_serialize.keys }
      }
    ).to_json
  end
end
