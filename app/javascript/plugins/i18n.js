import Vue from 'vue'
import I18n from '../i18n-js/index.js.erb'
export default () => {
  Vue.prototype.$i18n = I18n
}
