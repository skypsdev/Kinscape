<template>
  <TabSwitch :buttons="menuButtons" :simulate-path="hasSimulatedPath? 'communityVault': ''" />
</template>

<script>
import TabSwitch from '../../Elements/TabSwitch'

export default {
  components: { TabSwitch },
  props: {
    communityId: {
      validator: prop => typeof prop === 'string' || prop === null,
      required: true
    },
    hasSimulatedPath: {
      type:Boolean,
      default:false
    }
  },
  computed: {
    menuButtons() {
      const params = { id: this.communityId }

      return [
        {
          label: 'families.submenu.profile',
          title: 'families.submenu.profile_title',
          to: { name: 'showFamily', params }
        },
        {
          label: 'families.submenu.members',
          title: 'families.submenu.members_title',
          to: { name: 'members', params }
        },
        {
          label: 'families.submenu.invited_members',
          title: 'families.submenu.invited_members_title',
          to: { name: 'invitedMembers', params }
        },
        {
          label: 'families.submenu.vault',
          title: 'families.submenu.vault_title',
          to: { name: 'communityVault', params }
        }
      ]
    }
  }
}
</script>
