import Vue from 'vue'
const filestackKey = document.querySelector('meta[name="filestack-api-key"]')

export default () => {
  if (filestackKey) {
    Vue.prototype.$filestackKey = filestackKey.getAttribute('content')
  }
}
