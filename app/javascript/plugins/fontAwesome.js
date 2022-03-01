import Vue from 'vue'
import { FontAwesomeIcon } from '@fortawesome/vue-fontawesome'
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
  faSignature,
  faCircleNotch
} from '@fortawesome/free-solid-svg-icons'
import {
  faEnvelope,
  faCalendarAlt
} from '@fortawesome/free-regular-svg-icons'

export default () => {
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
    faSignature,
    faCircleNotch
  )
  Vue.component('fa-icon', FontAwesomeIcon)
}
