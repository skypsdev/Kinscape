class BaseSerializer
  include JSONAPI::Serializer

  # https://github.com/jsonapi-serializer/jsonapi-serializer/issues/53#issuecomment-689118659
  def self.belongs_to_encoded(type, **)
    belongs_to(type, { id_method_name: :uid }) do |o|
      o.send(type)
    end
  end

  def self.has_many_encoded(type, **)
    has_many(type, { id_method_name: :uid }) do |o|
      o.send(type)
    end
  end
end
