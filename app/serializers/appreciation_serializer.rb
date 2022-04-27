class AppreciationSerializer < BaseSerializer
  set_id :id

  attributes(
    :reaction,
    :created_at,
    :appreciable_type,
    :appreciable_id
  )
end
