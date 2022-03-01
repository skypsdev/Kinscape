import Vue from 'vue'
export default () => {
  Vue.prototype.$simpleLightbox = require('simple-lightbox')
  window.simpleLightbox = require('simple-lightbox')
  Vue.prototype.$simpleLightbox.defaults['urlAttribute'] = 'src'
  Vue.prototype.$simpleLightbox.defaults['captionAttribute'] = 'title'
}
