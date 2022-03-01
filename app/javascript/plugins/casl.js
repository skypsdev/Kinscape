import Vue from 'vue'
import { abilitiesPlugin } from '@casl/vue'
import { subject as an } from '@casl/ability'
import { store } from '../store'

export default () => {
  const ability = store.getters['core/ability']
  Vue.use(abilitiesPlugin, ability)
  Vue.prototype.$possible = (action, subject, conditions) => ability.can(action, an(subject, conditions))
}
