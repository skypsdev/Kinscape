import Vue from 'vue'
const directUploadPath =
  document.querySelector('meta[name="direct-upload-path"]')

export default () => {
  if (directUploadPath) {
    Vue.prototype.$directUploadPath = directUploadPath.getAttribute('content')
  }
}
