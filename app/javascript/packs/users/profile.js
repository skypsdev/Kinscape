import Vue from 'vue'
import VueResource from 'vue-resource'
import VModal from 'vue-js-modal'
import PortalVue from 'portal-vue'
import { library } from '@fortawesome/fontawesome-svg-core'
import {
  faPencilAlt,
  faTags,
  faMapMarker,
  faMapPin,
  faPhone,
  faMap,
  faRibbon,
  faCheck,
  faSignature
} from '@fortawesome/free-solid-svg-icons'
import {
  faEnvelope,
  faCalendarAlt
} from '@fortawesome/free-regular-svg-icons'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'

import I18n from '../../i18n-js/index.js.erb'
import UserProfile from '../../components/users/profile.vue'
import FlashMessage from '../../components/shared/flash-message.vue'

import { store } from '../../store'

library.add(
  faPencilAlt,
  faTags,
  faMapMarker,
  faMapPin,
  faPhone,
  faEnvelope,
  faCalendarAlt,
  faMap,
  faRibbon,
  faCheck,
  faSignature
)

Vue.use(require('vue-moment'))
Vue.use(VueResource)
Vue.use(VModal)
Vue.use(PortalVue)

Vue.component('fa-icon', FontAwesomeIcon)

Vue.prototype.$i18n = I18n

Vue.config.ignoredElements = ['trix-editor']

document.addEventListener('DOMContentLoaded', () => {
  const csrfTag = document.querySelector('meta[name="csrf-token"]')

  if (csrfTag) {
    Vue.http.headers.common['X-CSRF-Token'] = csrfTag.getAttribute('content')
  }

  const filestackKey = document.querySelector('meta[name="filestack-api-key"]')

  if (filestackKey) {
    Vue.prototype.$filestackKey = filestackKey.getAttribute('content')
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '#user-profile',
    components: { UserProfile },
    store
  })

  // eslint-disable-next-line no-new
  new Vue({
    el: '.profile-flash-message',
    components: { FlashMessage },
    store
  })
})
