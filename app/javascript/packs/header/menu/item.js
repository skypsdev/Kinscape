import Vue from 'vue'
import VModal from 'vue-js-modal'
import Dropdown from 'hsy-vue-dropdown'
import PortalVue from 'portal-vue'

import { store } from '../../../store'

import I18n from '../../../i18n-js/index.js.erb'
import MenuItem from '../../../components/header/menu/item.vue'
import MessageModal from '../../../components/messages/modal.vue'
import FlashMessage from '../../../components/shared/flash-message.vue'

Vue.use(VModal)
Vue.use(Dropdown)
Vue.use(PortalVue)

Vue.prototype.$i18n = I18n

document.addEventListener('DOMContentLoaded', () => {
  const menuItems = Array.from(document.querySelectorAll('.menu-item'))
  for (const menuItemHandler of menuItems) {
    // eslint-disable-next-line no-new
    new Vue({
      el: menuItemHandler,
      components: { MenuItem, MessageModal },
      store
    })
  }

  // eslint-disable-next-line no-new
  new Vue({
    el: '.flash-message',
    components: { FlashMessage },
    store
  })
})
