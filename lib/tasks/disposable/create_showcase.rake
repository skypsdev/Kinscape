# rubocop:disable Metrics, Lint, Layout
desc 'Showcase'
task create_showcase: :environment do
  users = [
    'Melissa Jones', 'Nick Jones', 'Bill Jones', 'Nancy Jones', 'Linda Vasquez', 'Frank Jones', 'Miranda Ruiz',
    'Christina Ruiz', 'Jeff Smith', 'Kate Martinez', 'Adrianna Smith', 'Tim Jackson', 'Anil Srinivasan', 'Li Cheung',
    'Anna Williams', 'John Dulay', 'Cindy Nguyen', 'Sarah Jones', 'Marcus Garcia', 'Frank Lopez', 'Sarah Williams',
    'Aliyah Roberts', 'Misty Moore', 'John Smith', 'Felicia Ana'
  ]
  users_without_avatar = ['John Smith', 'Felicia Ana']

  kinship_ids = users.map do |full_name|
    puts "creating user #{full_name}"
    user_name_plus = full_name.downcase.split.join('+')
    user = User.create!(
      first_name: full_name.split.first,
      last_name: full_name.split.last,
      email: "kintest+#{user_name_plus}@kinscape.com",
      password: "#{user_name_plus}+asd123",
      showcase: true,
      terms_and_conditions: true
    )
    if users_without_avatar.exclude?(full_name)
      blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(Rails.root.join("lib/assets/showcase/kinship/#{user_name_plus}.jpg")),
        filename: "#{user_name_plus}.jpg",
        content_type: 'image/jpeg'
      )
      personal_kinship = user.personal_kinship
      personal_kinship.avatar = blob
      personal_kinship.save validate: false
    end
    user.all_kinships.pluck(:id)
  end

  melissa = User.find_by(email: 'kintest+melissa+jones@kinscape.com')

  ###########################

  families =
    [
      { motto: '', user_name: 'Melissa Jones', family_name: 'Miranda & Jeff\'s Wedding', type: 'Family' },
      { motto: '', user_name: 'Melissa Jones', family_name: 'Shooting Stars Soccer', type: 'Team' },
      { motto: '', user_name: 'Melissa Jones', family_name: 'Life Long Friends', type: 'Community' },
      { motto: '', user_name: 'Melissa Jones', family_name: 'Where\'s Buddy?', type: 'Family' },
      { motto: '', user_name: 'Melissa Jones', family_name: 'Crafts & creative stuff', type: 'Community' },
      { motto: '', user_name: 'Melissa Jones', family_name: 'Happy Valley Preschool', type: 'Community' },
      { motto: '', user_name: 'Marcus Garcia', family_name: 'Tri-Cities Soccer League', type: 'Community' },
      { motto: '', user_name: 'Frank Lopez', family_name: 'Parents of Westmont Elementary', type: 'School' },
      { motto: '', user_name: 'Sarah Williams', family_name: 'Book Club on Tuesdays', type: 'Club' },
      { motto: '', user_name: 'Aliyah Roberts', family_name: 'Senior Project Manager\'s Guild', type: 'Organization' },
      { motto: '', user_name: 'Misty Moore', family_name: 'Healthy Kids Meals on the Go', type: 'Community' },
      { motto: '', user_name: 'John Smith', family_name: 'Smith Family & Friends', type: 'Community' },
      { motto: '', user_name: 'Felicia Ana', family_name: 'Yoga with Felicia', type: 'Community' },
      {
        user_name: 'Melissa Jones',
        family_name: 'Jones Family Adventures',
        type: 'Family',
        motto: 'Always on the go and living the dream',
        description: 'The kids are growing so fast and we\'re always struggling to keep up, so we thought it would be a great idea to form a community where family and friends can see what we\'re up to and enjoy our family photos. We hope you enjoy them and keep in touch through Kinscape. It\'s a great way to share our adventures, especially as our lives only seem to get busier!'
      }
    ]

  families.each do |family_data|
    puts "creating family #{family_data[:family_name]}"
    family_name_plus = family_data[:family_name].downcase.split.join('+')
    user_name_plus = family_data[:user_name].downcase.split.join('+')
    family_blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("lib/assets/showcase/families/#{family_name_plus}.jpg")),
      filename: "#{family_name_plus}.jpg",
      content_type: 'image/jpeg'
    )
    user = User.find_by(email: "kintest+#{user_name_plus}@kinscape.com")
    family = Families::CreationService.call(
      user,
      name: family_data[:family_name],
      cover: family_blob.signed_id,
      family_type: family_data[:type],
      motto: family_data[:motto],
      description: family_data[:description],
      showcase: true
    )
    kinship = family.admin_kinship
    kinship.avatar = user.personal_kinship.avatar.blob.signed_id if user.personal_kinship.avatar.blob
    kinship.save validate: false
    kinship_ids << kinship.id
    next if family_data[:user_name] == 'Melissa Jones'

    if users_without_avatar.include?(family_data[:user_name])
      family.invitations.create(
        recipient: melissa,
        email: melissa.email,
        role: :guest,
        message: '',
        sender: user,
        showcase: true
      )
    else
      kinship = family.kinships.create!(
        user: melissa,
        role: :member,
        access_type: 'default',
        nickname: 'Melissa Jones'
      )
      kinship_ids << kinship.id
    end
  end

  ######################################
  puts 'creating followers'
  followers = [
    'Nick Jones',
    'Bill Jones',
    'Nancy Jones',
    'Linda Vasquez',
    'Frank Jones',
    'Miranda Ruiz',
    'Christina Ruiz',
    'Jeff Smith'
  ]
  followers.each do |follower_full_name|
    # following table
    user_name_plus = follower_full_name.downcase.split.join('+')
    user = User.find_by(email: "kintest+#{user_name_plus}@kinscape.com")
    kinship = user.kinships.create!(
      family: melissa.personal_family,
      role: :guest,
      access_type: 'personal',
      nickname: follower_full_name,
      showcase: true,
      avatar: user.personal_kinship.avatar.blob.signed_id
    )
    kinship_ids << kinship.id
    # follows me table
    other_kinship = melissa.kinships.create!(
      family: user.personal_family,
      role: :guest,
      access_type: 'personal',
      nickname: 'Melissa Jones',
      showcase: true
    )
    kinship_ids << other_kinship.id
  end

  ######################################
  # generic followers
  48.times do |x|
    user = User.create!(
      first_name:  "Z-#{Faker::Name.first_name}",
      last_name: Faker::Name.last_name,
      email: "kintest+faker#{x}@kinscape.com",
      password: "faker#{x}+asd123",
      showcase: true,
      terms_and_conditions: true
    )
    kinship_ids << user.all_kinships.pluck(:id)
    kinship = melissa.kinships.create!(
      family: user.personal_family,
      role: :guest,
      access_type: 'personal',
      nickname: 'Melissa Jones',
      showcase: true
    )
    kinship_ids << kinship.id
    next if x > 33

    other_kinship = user.kinships.create!(
      family: melissa.personal_family,
      role: :guest,
      access_type: 'personal',
      nickname: user.name,
      showcase: true
    )
    kinship_ids << other_kinship.id
  end

  ######################################
  # my life invitations sent

  puts 'creating my life invitations'
  invitations = [
    'Kate Martinez',
    'Adrianna Smith',
    'Tim Jackson',
    'Anil Srinivasan'
  ]
  invitations.each do |invitation_full_name|
    user_name_plus = invitation_full_name.downcase.split.join('+')
    user = User.find_by(email: "kintest+#{user_name_plus}@kinscape.com")

    melissa.personal_family.invitations.create(
      recipient: user,
      email: user.email,
      role: :guest,
      message: '',
      sender: melissa,
      showcase: true
    )
  end

  melissa.personal_family.invitations.create(
    recipient: nil,
    email: 'heather.roy@email.com',
    role: :guest,
    message: '',
    sender: melissa,
    showcase: true
  )

  ######################################
  # invitations received

  invitation_full_name = 'Li Cheung'
  user_name_plus = invitation_full_name.downcase.split.join('+')
  user = User.find_by(email: "kintest+#{user_name_plus}@kinscape.com")
  user.personal_family.invitations.create(
    recipient: melissa,
    email: melissa.email,
    role: :guest,
    message: '',
    sender: user,
    showcase: true
  )

  ######################################
  # jones family chapters

  puts 'creating jones family chapters'
  jones_family = melissa.all_families.find_by(name: 'Jones Family Adventures')
  chapter_params = {
    showcase: true,
    title: 'Why San Francisco?',
    rich_body: 'The West Coast has always appealed to Nick and I as a great place to raise the kids and be closer to some of my family. But for years we put off making any major decisions to see where our careers took us. Then we had the kids and realized the clock was ticking. Then, my manager mentioned that there was an opening in the San Francisco office that came with a promotion and moving assistance, if I was interested. She gave me a few days to decide but I knew straightaway … '
  }
  ::Chapters::CreationService.call(jones_family, chapter_params, melissa)
  chapter_params = {
    showcase: true,
    title: 'Buying our new home',
    rich_body: ''
  }
  ::Chapters::CreationService.call(jones_family, chapter_params, melissa)
  chapter_params = {
    showcase: true,
    title: 'The day of the big move and how we survived the chaos',
    rich_body: ''
  }
  ::Chapters::CreationService.call(jones_family, chapter_params, melissa)

  ######################################
  # jones family members
  puts 'creating jones family members'

  offline = [
    'Antonio Vasquez',
    'Ashley Jones'
  ]
  offline.each do |offline_name|
    offline_plus = offline_name.downcase.split.join('+')
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("lib/assets/showcase/kinship/#{offline_plus}.jpg")),
      filename: "#{offline_plus}.jpg",
      content_type: 'image/jpeg'
    )
    kinship = jones_family.kinships.create!(
      user: nil,
      role: :offline_member,
      access_type: 'default',
      nickname: offline_name,
      avatar: blob.signed_id,
      showcase: true
    )
    kinship_ids << kinship.id
  end

  users = [
    { name: 'Nancy Jones', role: 'member' },
    { name: 'Bill Jones', role: 'member' },
    { name: 'Linda Vasquez', role: 'member' },
    { name: 'Nick Jones', role: 'co_admin' },
    { name: 'Miranda Ruiz', role: 'member' },
    { name: 'Christina Ruiz', role: 'guest' },
    { name: 'Jeff Smith', role: 'member' }
  ]
  users.each do |f_user|
    name_plus = f_user[:name].downcase.split.join('+')
    blob = ActiveStorage::Blob.find_by(filename: "#{name_plus}.jpg")
    user = User.find_by(email: "kintest+#{name_plus}@kinscape.com")
    kinship = jones_family.kinships.create!(
      user: user,
      role: f_user[:role],
      access_type: 'default',
      nickname: f_user[:name],
      avatar: blob.signed_id,
      showcase: true
    )
    kinship_ids << kinship.id
  end

  ######################################
  # jones family invitations
  puts 'creating jones family invitations'

  jones_invitations = [
    { name: 'Anna Williams', role: 'guest' },
    { name: 'John Dulay', role: 'member' },
    { name: 'Cindy Nguyen', role: 'guest' },
    { name: nil, email: 'alicia.gomez@email.com', role: 'guest' },
    { name: nil, email: 'maria_thorn@email.com', role: 'guest' },
    { name: 'Frank Jones', role: 'member' },
    { name: 'Sarah Jones', role: 'member' }
  ]

  jones_invitations.each do |hash|
    if hash[:name].nil?
      recipient = nil
      email = hash[:email]
    else
      name_plus = hash[:name].downcase.split.join('+')
      recipient = User.find_by(email: "kintest+#{name_plus}@kinscape.com")
      email = recipient.email
    end

    jones_family.invitations.create!(
      recipient: recipient,
      email: email,
      role: hash[:role],
      message: '',
      sender: jones_family.admin,
      showcase: true
    )
  end

  stories = [
    {
      title: 'Emma\'s First Soccer Game',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Moving to San Francisco',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Hawaii vacation',
      family_name: 'Jones Family Adventures',
      user_name: 'Nick'
    },

    {
      title: 'Moms\' day out!',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Christmas 2020',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Halloween 2020',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Thanksgiving with Grandma',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Summer Vacation 2019',
      family_name: 'Jones Family Adventures',
      user_name: 'Melissa'
    },
    {
      title: 'Girlfriends Christmas ornament exchange',
      family_name: 'Crafts & creative stuff'
    },
    {
      title: 'Shooting Stars vs Mini Titans',
      family_name: 'Shooting Stars Soccer'
    },
    {
      title: 'Lucas at the Zoo',
      family_name: 'Life Long Friends'
    },
    {
      title: 'Annual review notes',
      family_name: 'Private Stories'
    },
    {
      title: '5-minute recipes',
      family_name: 'Healthy Kids Meals on the Go'
    },
    {
      title: 'Weekend Sailing with Jackie',
      family_name: 'My Life Stories',
      categories: %w[Families Friends],
      created_at: DateTime.new(2019,6,2),
      description: 'Growing up on the East Coast, every summer was spent on the beaches of Florida, swimming, playing in the sand, and sailing. Pops was an avid sailor and took us out almost every day we were there. So when my dear friend Jackie, who\'s an avid sailor and crews on a professional race team, came out to California Race Week and invited me sailing for a day, I jumped at the chance. And what an amazing day we had!'
    }
  ]

  stories.each do |story_hash|
    puts "creating story #{story_hash[:title]}"
    family = melissa.all_families.find_by(name: story_hash[:family_name])
    user = if story_hash[:user_name].nil?
              family.admin
            else
              family.users.find_by(first_name: story_hash[:user_name])
            end
    title_plus = story_hash[:title].downcase.split.join('+')
    blob = if story_hash[:family_name] != 'Private Stories'
             ActiveStorage::Blob.create_and_upload!(
               io: File.open(Rails.root.join("lib/assets/showcase/stories/#{title_plus}.jpg")),
               filename: "#{title_plus}.jpg",
               content_type: 'image/jpeg'
             )
           end
    story_params = {
      showcase: true,
      title: story_hash[:title],
      cover: blob&.signed_id,
      description: story_hash[:description],
      categories: story_hash[:categories],
      created_at: DateTime.new(2019,6,2)
    }
    story = ::Stories::CreationService.call(story_params, user)
    publication_params = { families_ids: [family.id] }
    ::Publications::CreationService.call(story, user, publication_params, send_mail: false).first
    story.publications.update_all(showcase: true)
  end

  kinships = Kinship.where(id: kinship_ids.flatten)
  kinships.update_all(showcase: true)
  Family.where(id: kinships.pluck(:family_id)).update_all(showcase: true)

  puts 'creating sections for story Weekend Sailing with Jackie'

  story = melissa.stories.find_by(title: 'Weekend Sailing with Jackie')
  section_params = {
    showcase: true,
    title: 'Breakfast by the dock',
    created_at: DateTime.new(2019,6,2),
    rich_body: 'Pops always used to tell us to eat a hearty breakfast with plenty of carbs (but not too much sugar) before sailing, so Jackie and I got to the docks early and found a great diner to fill up on oatmeal, toast, and orange juice. The place was packed with sailing types like us, keen to get out on the water and enjoy a day\'s sail. Jackie told me all about her latest race on a trimaran in the Caribbean and I thought how much fun it would be for Nick and I to take the kids there one day.'
  }
  ::Sections::CreationService.call(story.private_publication, melissa, section_params)

  section_blob = ActiveStorage::Blob.create_and_upload!(
    io: File.open(Rails.root.join('lib/assets/showcase/stories/story+section.png')),
    filename: 'story+section.png',
    content_type: 'image/jpeg'
  )
  section_params = {
    showcase: true,
    title: 'Jackie\'s sailboat',
    created_at: DateTime.new(2019,6,2),
    rich_body: ActionText::Content.new(
      'Although this isn\'t the boat I sailed in, we did get to see it out for a practice run. I was quite envious.'
    ).append_attachables(section_blob)
  }
  ::Sections::CreationService.call(story.private_publication, melissa, section_params)

  section_params = {
    showcase: true,
    title: 'Sailing in the San Francisco Bay: first stop Angel Island for a hike and tour',
    created_at: DateTime.new(2019,6,3),
    rich_body: 'Jackie had said to be flexible on our route for the day, based on weather conditions and the current. This can change at any time in the San Francisco Bay which makes planning a little challenging but also adds to the sense of adventure. We knew we wanted to stop at Angel Island and either hike or picnic depending on timing, and it worked out well that we should stop there first for a hike before later heading to the city and docking at a restaurant for lunch.<br><br>Luckily, there were plenty of spots to moor when we got there and Jackie took us in like the pro she is, even though the 39-foot sailboat she\'d rented was unfamiliar to her. I helped of course, but immediately sensed I was not in as good shape as I was when we\'d go sailing with Pops and made a mental note to self to try to get to the gym more often.<br><br>The island was beautiful and thank goodness the sun broke through the fog there quite early today. A lot of people came off one of the tour ferries and were renting bikes. I felt incredibly lucky to walk off a sailboat instead and start our wonderful hike up the steep hill. Once we got there, the views were spectacular. The pictures are in the next chapter.'
  }
  ::Sections::CreationService.call(story.private_publication, melissa, section_params)


  ################
  puts 'creating Melissa profiles avatars'

  melissa_blob = melissa.personal_kinship.avatar.blob
  melissa_blob2 = ActiveStorage::Blob.create_and_upload!(
    io: File.open(Rails.root.join('lib/assets/showcase/kinship/melissa+2.jpg')),
    filename: 'melissa+2.jpg',
    content_type: 'image/jpeg'
  )

  families =
    [
      { family_name: 'Miranda & Jeff\'s Wedding', blob: melissa_blob },
      { family_name: 'Life Long Friends', blob: melissa_blob2 },
      { family_name: 'Private Stories', blob: melissa_blob2 },
      { family_name: 'Parents of Westmont Elementary', blob: melissa_blob2 },
      { family_name: 'Book Club on Tuesdays', blob: melissa_blob }
    ]

  families.each do |hash|
    family = melissa.all_families.find_by(name: hash[:family_name])
    kinship = melissa.all_kinships.find_by(family_id: family.id)
    kinship.avatar = hash[:blob].signed_id
    kinship.save validate: false
  end


  ################
  puts 'creating Melissa profiles attrs'

  family = melissa.all_families.find_by(name: 'Jones Family Adventures')
  kinship = melissa.all_kinships.find_by(family_id: family.id)
  kinship.profile_attrs = {'emails'=>[{'id'=>0, 'type'=>'text', 'title'=>'Home', 'value'=>[{'name'=>'email', 'value'=>'michelle@email.com'}]}], 'addresses'=>[{'id'=>0, 'type'=>'text', 'title'=>'Home', 'value'=>[{'name'=>'addressLine1', 'value'=>'205 Blackberry Lane'}, {'name'=>'addressLine2', 'value'=>' San Francisco'}, {'name'=>'county', 'value'=>''}, {'name'=>'postcode', 'value'=>'CA 94555'}, {'name'=>'country', 'value'=>' USA'}]}], 'locations'=>[{'id'=>0, 'type'=>'text', 'title'=>'Current', 'value'=>[{'name'=>'location', 'value'=>'San Francisco'}]}], 'phone_numbers'=>[{'id'=>0, 'type'=>'text', 'title'=>'Mobile', 'value'=>[{'name'=>'phoneNumber', 'value'=>'+415-555-5555'}]}], 'profile_attrs_order'=>[0, 1, 9, 2, 3, 4, 5, 7, 8]}
  kinship.save validate: false


  ################
  puts 'creating Jones family vault files'

  family = melissa.all_families.find_by(name: 'Jones Family Adventures')
  entries = Dir.entries(Rails.root.join('lib/assets/showcase/family_vault')) - %w[. ..]
  entries.each do |file_name|
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("lib/assets/showcase/family_vault/#{file_name}")),
      filename: file_name
    )
    blob.attachments.create!(
      name: 'files',
      record: family.vault,
      box: nil,
      family: family,
      user: melissa
    )
  end

  ################
  puts 'creating private vault files'

  entries = Dir.entries(Rails.root.join('lib/assets/showcase/private_vault')) - %w[. ..]
  entries.each do |file_name|
    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join("lib/assets/showcase/private_vault/#{file_name}")),
      filename: file_name
    )
    blob.attachments.create!(
      name: 'files',
      record: melissa.vault,
      box: nil,
      family: nil,
      user: melissa
    )
  end

  # %w[User Family Story Kinship Publication Invitation Chapter].each do |c|
  #   next if c.constantize.pluck(:showcase).uniq == [true]
  #
  #   puts 'some records dont have showcase flag set to true'
  #   puts "class: #{c}"
  # end
end
# rubocop:enable
