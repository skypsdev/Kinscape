import Vue from 'vue'
import VueResource from 'vue-resource'
import VTooltip from 'v-tooltip'

import I18n from '../../i18n-js/index.js.erb'
import SubHeader from '../../components/families/sub-header.vue'

Vue.use(VueResource)
Vue.use(VTooltip)

Vue.prototype.$i18n = I18n

document.addEventListener('DOMContentLoaded', () => {
  const csrfTag = document.querySelector('meta[name="csrf-token"]')

  if (csrfTag) {
    Vue.http.headers.common['X-CSRF-Token'] = csrfTag.getAttribute('content')
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.for-header',
    components: { SubHeader },
    data () {
      return {
        showConfirm: false,
        showWarning: false
      }
    }
  })
})
