Story.destroy_all
Kinship.destroy_all
Family.destroy_all
User.destroy_all

3.times do |x|
  User.create!(
    first_name: "User name #{x + 1}",
    last_name: "User last #{x + 1}",
    email: "kintest+#{x + 1}@kinscape.com",
    password: 'asd123',
    confirmed_at: Time.current
  )
end

%w[red blue green].each_with_index do |color, x|
  user = User.find_by(first_name: "User name #{x + 1}")
  filename = "family_#{color}.png"
  blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
    filename: filename,
    content_type: 'image/jpeg'
  )
  Families::CreationService.call(user, name: color, cover: blob.signed_id)
end

%w[car motorcycle bicycle].each_with_index do |name, x|
  user = User.find_by(first_name: "User name #{x + 1}")
  filename = "#{name}.jpg"
  story_blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
    filename: filename,
    content_type: 'image/jpeg'
  )

  story = user.stories.create!(title: name.capitalize, cover: story_blob)
  Family.all.each do |family|
    filename = "#{family.name}_#{x + 1}.jpg"
    kinship_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
      filename: filename,
      content_type: 'image/jpeg'
    )
    if (kinship = family.kinship_for(user))
      kinship.update(name: "Kinship name #{x + 1}", avatar: kinship_blob)
    else
      family.kinships.create!(user: user, role: :member, nickname: "Kinship name #{x + 1}", avatar: kinship_blob)
    end
    story.publications.create!(family_id: family.id)
  end
end

puts '++++LOGIN DATA++++++++'
puts 'user: kintest+1@kinscape.com'
puts 'user: kintest+2@kinscape.com'
puts 'user: kintest+3@kinscape.com'
puts 'password: asd123'
puts '++++++++++++++++++++++'
