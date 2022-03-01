import Vue from 'vue'
const blobPath = document.querySelector('meta[name="blob-path"]')

export default () => {
  if (blobPath) {
    Vue.prototype.$blobPath = blobPath.getAttribute('content')
  }
}
