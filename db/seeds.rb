ActiveRecord::Base.transaction do
  3.times do |x|
    puts "create user #{x}"
    User.create!(
      first_name: Faker::Name.first_name,
      last_name: "#{Faker::Name.last_name} #{x + 1}",
      email: "kintest+#{x + 1}@kinscape.com",
      password: 'asd123',
      confirmed_at: Time.current,
      terms_and_conditions: true
    )
  end

  images_names = %w[car motorcycle bicycle]
  families_names = %w[red green blue]
  family_type =  %w[Family Community Club Team School]

  families_names.each_with_index do |color, x|
    puts "creating family #{color}"
    user = User.find_by(email: "kintest+#{x + 1}@kinscape.com")
    filename = "family_#{color}.png"
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
      filename: filename,
      content_type: 'image/jpeg'
    )
    family = Families::CreationService.call(
      user,
      name: color,
      cover: blob.signed_id,
      motto: Faker::Company.catch_phrase,
      family_type: family_type.sample
    )
    chapter_params = {
      title: Faker::Lorem.word.capitalize,
      rich_body: ActionText::Content.new(Faker::Lorem.paragraph(sentence_count: 10)).append_attachables(blob)
    }
    ::Chapters::CreationService.call(family, chapter_params, user)
  end

  images_names.each_with_index do |name, x|
    puts "creating story #{name}"
    user = User.find_by(email: "kintest+#{x + 1}@kinscape.com")
    filename = "#{name}.jpg"
    story_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
      filename: filename,
      content_type: 'image/jpeg'
    )

  story = user.stories.create!(title: name.capitalize, cover: story_blob)
  section_params = {
    title: Faker::Lorem.word.capitalize,
    rich_body: ActionText::Content.new(Faker::Lorem.paragraph(sentence_count: 10)).append_attachables(story_blob),
    position: 0
  }
  ::Sections::CreationService.call(story.private_publication, user, section_params)

    Family.where(showcase: false).default_access.each do |family|
      filename = "#{family.name}_#{x + 1}.jpg"
      kinship_blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
        filename: filename,
        content_type: 'image/jpeg'
      )
      name = "#{Faker::Superhero.name} (K#{x + 1})"
      kinship = family.kinship_for(user)
      kinship&.update!(name: name, avatar: kinship_blob)
      kinship ||= family.kinships.create!(
        user: user, role: :member, nickname: name, avatar: kinship_blob
      )
      chapter_params = {
        title: Faker::Lorem.word.capitalize,
        rich_body: ActionText::Content.new(Faker::Lorem.paragraph(sentence_count: 10)).append_attachables(kinship_blob)
      }
      ::Chapters::CreationService.call(kinship, chapter_params, user)
      ::Publications::CreationService.call(story, user, { families_ids: [family.id] }, send_mail: false)
    end
  end

  # community story
story = Story.find_by(title: 'Car')
family = Family.default_access.first
publication = ::Publications::CreationService.call(
  story, story.user, { families_ids: [family.id], share_type: :community }, send_mail: false
).first
section_params = {
  title: Faker::Lorem.word.capitalize,
  rich_body: Faker::Lorem.paragraph(sentence_count: 10),
  position: 0
}
contribution = ::Sections::CreationService.call(
  story.private_publication, family.users.where.not(id: publication.story.user_id).first, section_params
)

User.where(showcase: false).find_each do |user|
    puts "adding kinships for #{user.name}"
    User.where.not(id: user.id).where(showcase: false).each do |other_user|
      if user.all_kinships.where(family: other_user.personal_family).blank?
        # follower
        user.kinships.create!(
          family: other_user.personal_family,
          role: :guest,
          access_type: 'personal',
          nickname: "Personal #{user.name}",
          avatar: ActiveStorage::Blob.order(Arel.sql('RANDOM()')).first
        )
      end
      next if other_user.all_kinships.where(family: user.personal_family).present?

    # following
    other_user.kinships.create!(
      family: user.personal_family,
      role: :guest,
      access_type: 'personal',
      nickname: "Personal #{other_user.name}",
      avatar: ActiveStorage::Blob.order(Arel.sql('RANDOM()')).first
    )
  end
end

  [1, 2, 3].each do |number|
    user = User.find_by(email: "kintest+#{number}@kinscape.com")
    puts "adding personal avatar for #{user.name}"
    filename = "black_#{number}.jpg"
    kinship_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("spec/fixtures/files/#{filename}")),
      filename: filename,
      content_type: 'image/jpeg'
    )
    user.personal_kinship.update!(avatar: kinship_blob)
  end
end

puts '++++LOGIN DATA++++++++'
puts 'user: kintest+1@kinscape.com'
puts 'user: kintest+2@kinscape.com'
puts 'user: kintest+3@kinscape.com'
puts 'password: asd123'
puts '++++++++++++++++++++++'
