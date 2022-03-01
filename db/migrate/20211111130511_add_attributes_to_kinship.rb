class AddAttributesToKinship < ActiveRecord::Migration[6.1]
  def change
    add_column :kinships, :profile_attrs, :jsonb, null: false, default: {
      emails: [{
                 value: '',
                 name: 'email',
               }],
      addresses: [{
                    value: '',
                    name: 'address',
                  }],
      phone_numbers: [{
                        value: '',
                        name: 'phone number',
                      }],
      locations: [{
                    value: '',
                    name: 'location',
                  }],
      birth_place: '',
      birth_date: '',
      facebook: '',
      instagram: '',
      website: ''
    }
  end
end
