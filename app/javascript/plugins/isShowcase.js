import Vue from 'vue'
const isShowcase =
  document.querySelector('meta[name="is-showcase"]')

export default () => {
  if (isShowcase) {
    Vue.prototype.$isShowcase = isShowcase.getAttribute('content') === 'true'
  }
}
