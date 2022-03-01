# TODO-MEMBER
# rubocop:disable all
desc 'Migrate profile attrs to new filed'
task kinship_profile_attrs: :environment do
  Kinship.find_each do |kinship|
    kinship.profile_attrs = {
      emails: [
        {
          email: kinship.email || ''
        }
      ],
      website: '',
      facebook: '',
      addresses: [
        {
          address: kinship.address || ''
        }
      ],
      instagram: '',
      locations: [
        {
          location: kinship.location || ''
        }
      ],
      birth_date: kinship.birth_date,
      birth_place: kinship.birth_place || '',
      phone_numbers: [
        {
          phone_number: kinship.phone || ''
        }
      ]
    }
  end
end
# rubocop:enable all
