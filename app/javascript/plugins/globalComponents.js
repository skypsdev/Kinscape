import Vue from 'vue'
import Icon from '../components/Elements/Icons/Icon'
import vSelect from 'vue-select'
import 'vue-select/dist/vue-select.css'
import VTooltip from 'v-tooltip'
import Dropdown from 'hsy-vue-dropdown'
import VModal from 'vue-js-modal'
import PortalVue from 'portal-vue'
import InfiniteLoading from 'vue-infinite-loading'

export default () => {
  Vue.component('Icon', Icon)
  Vue.component('v-select', vSelect)

  Vue.use(Dropdown)
  Vue.use(VModal, { dialog: true })
  Vue.use(VTooltip)
  Vue.use(PortalVue)
  Vue.use(InfiniteLoading)
}
