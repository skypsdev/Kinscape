import Vue from 'vue'
import vuetify from '../plugins/vuetify'
import router from './router'
import { store } from '../store'
import VueResource from 'vue-resource'
import i18n from '../plugins/i18n'
import externalLinks from '../plugins/externalLinks'
import blobPath from '../plugins/blobPath'
import directUploadPath from '../plugins/directUploadPath'
import filestackKey from '../plugins/filestackKey'
import fontAwesome from '../plugins/fontAwesome'
import globalComponents from '../plugins/globalComponents'
import globalUtils from '../plugins/globalUtils'
import globalDirectives from '../plugins/globalDirectives'
import isShowcase from '../plugins/isShowcase'
import simpleLightbox from '../plugins/simpleLightbox'
import casl from '../plugins/casl'
import { globalMixin } from '@/mixins/globalMixin'
import App from './App'

Vue.config.ignoredElements = ['trix-editor']
Vue.config.devtools = true
Vue.use(VueResource)
Vue.mixin(globalMixin)

document.addEventListener('DOMContentLoaded', () => {
  i18n()
  filestackKey()
  externalLinks()
  directUploadPath()
  blobPath()
  fontAwesome()
  isShowcase()
  simpleLightbox()
  globalComponents()
  globalUtils()
  globalDirectives()
  casl()
  // eslint-disable-next-line no-new
  new Vue({
    el: '#app',
    components: { App },
    router,
    store,
    vuetify
  })
})
