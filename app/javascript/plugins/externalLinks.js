import Vue from 'vue'
const externalLinks = document.querySelector('meta[name="external-links"]')

export default () => {
  if (externalLinks) {
    Vue.prototype.$externalLinks = JSON.parse(
      externalLinks.getAttribute('content')
    )
  }
}
