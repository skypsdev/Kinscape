import Vue from 'vue'
const $i18n = Vue.prototype.$i18n

export default {
  default: {
    options: [],
    value: [{ name: 'default' }]
  },
  place_of_birth: {
    value: [{ name: 'place_of_birth' }]
  },
  relationships: {
    options: [
      { title: $i18n.t('relationships.mother') },
      { title: $i18n.t('relationships.father') },
      { title: $i18n.t('relationships.son') },
      { title: $i18n.t('relationships.daughter') },
      { title: $i18n.t('relationships.spouse') }
    ],
    value: [{ name: 'relationships' }]
  },
  birth_date: {
    value: [{ name: 'birth_date' }]
  },
  phone_numbers: {
    options: [
      {
        title: $i18n.t('phone_types.mobile'),
        value: 'mobile'
      },
      {
        title: $i18n.t('location_types.home'),
        value: 'home'
      },
      {
        title: $i18n.t('location_types.work'),
        value: 'work'
      },
      {
        title: $i18n.t('location_types.school'),
        value: 'school'
      },
      {
        title: $i18n.t('phone_types.home_fax'),
        value: 'home_fax'
      },
      {
        title: $i18n.t('phone_types.work_fax'),
        value: 'work_fax'
      },
      {
        title: $i18n.t('phone_types.pager'),
        value: 'pager'
      }
    ],
    value: [{ name: 'phoneNumber' }]
  },
  socials: {
    options: [
      { title: $i18n.t('social_types.facebook') },
      { title: $i18n.t('social_types.instagram') },
      { title: $i18n.t('social_types.twitter') },
      { title: $i18n.t('social_types.linkedin') },
      { title: $i18n.t('social_types.skype') },
      { title: $i18n.t('social_types.hangouts') },
      { title: $i18n.t('social_types.sina_weibo') }
    ],
    value: [{ name: 'social' }]
  },
  emails: {
    options: [
      {
        title: $i18n.t('location_types.home'),
        value: 'home'
      },
      {
        title: $i18n.t('location_types.work'),
        value: 'work'
      },
      {
        title: $i18n.t('location_types.school'),
        value: 'school'
      }
    ],
    value: [{ name: 'email' }]
  },
  locations: {
    options: [{ title: $i18n.t('location_types.current_location') }],
    value: [{ name: 'location' }]
  },
  websites: {
    options: [
      { title: $i18n.t('website_types.personal') },
      { title: $i18n.t('website_types.work') }
    ],
    value: [{ name: 'website' }]
  },
  date: {
    options: [
      { title: $i18n.t('date_types.birth_date') },
      { title: $i18n.t('date_types.death_date') }
    ],
    value: [
      {
        type: 'text',
        name: 'day'
      },
      {
        type: 'text',
        name: 'month'
      },
      {
        type: 'text',
        name: 'year'
      }
    ]
  },
  addresses: {
    options: [
      { title: $i18n.t('location_types.home') },
      { title: $i18n.t('address_types.childhood_home') },
      { title: $i18n.t('location_types.work') },
      { title: $i18n.t('location_types.school') },
      { title: $i18n.t('address_types.previous_address') }
    ],
    value: [
      {
        type: 'text',
        name: 'addressLine1'
      },
      {
        type: 'text',
        name: 'addressLine2'
      },
      {
        type: 'text',
        name: 'county'
      },
      {
        type: 'text',
        name: 'postcode'
      },
      {
        type: 'text',
        name: 'country'
      }
    ]
  }
}
