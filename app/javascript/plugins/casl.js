import Vue from 'vue'
import { abilitiesPlugin } from '@casl/vue'
import { subject as an } from '@casl/ability'
import { store } from '../store'

export default () => {
  const ability = store.getters['core/ability']
  Vue.use(abilitiesPlugin, ability)
  Vue.prototype.$possible = (action, subject, conditions) => ability.can(action, an(subject, conditions))
}

// this.$possible('destroy', 'Appreciation', {userId: 1})
// this.$possible('read', 'Family', {kinships: { userId: 1 }})
// this.$possible('destroy', 'Appreciation', {userId: 1})
// this.$possible('manage', 'Comment', {userId: 1})
// this.$possible('read', 'Kinship', {familyId: 1 })
// this.$possible('read', 'Kinship', {familyId: '5Wfkcvp6skd' })
// this.$possible('add_boxes_to_vault', 'Vault', {ownerType: "Family", ownerId: 1})
// this.$possible('add_boxes_to_vault', 'Vault', {ownerType: "Family", ownerId: '5Wfkcvp6skd'})
// this.$possible('read', 'Family', {kinships: { userId: 1 }}))
// this.$possible('read', 'Family',  { kinships: [{ userId: 1 }] }))
// this.$possible('read', 'Box',  { vault: [{ ownerType: 'Family', ownerId: 1 }] })
// this.$possible('read', 'Box',  { vault: { ownerType: 'Family', ownerId: 1 } })
