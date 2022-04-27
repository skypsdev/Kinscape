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
          id:'intro-communities-community-profile-1',
          label: 'families.submenu.profile',
          title: 'families.submenu.profile_title',
          to: { name: 'showFamily', params }
        },
        {
          id:'intro-communities-community-members',
          label: 'families.submenu.members',
          title: 'families.submenu.members_title',
          to: { name: 'members', params },
          tooltip: {
            position: 'bottom left',
            name: "communityMembers",
            icons: ["mdi-plus-circle-outline"],
            title: this.$i18n.t('tooltips.community_members_title'),
            description: this.$i18n.t('tooltips.community_members_description')
          }
        },
        {
          label: 'families.submenu.invited_members',
          id: 'intro-communities-community-invitations',
          title: 'families.submenu.invited_members_title',
          to: { name: 'invitedMembers', params }
        },
        {
          id:'intro-communities-community-vault',
          label: 'families.submenu.vault',
          title: 'families.submenu.vault_title',
          to: { name: 'communityVault', params }
        }
      ]
    }
  }
}
</script>
