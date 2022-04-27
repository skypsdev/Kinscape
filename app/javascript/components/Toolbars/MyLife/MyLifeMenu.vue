<template>
  <TabSwitch
    :buttons="menuButtons"
    :simulate-path="hasSimulatedPath"
  />
</template>

<script>
import { mapActions, mapState } from 'vuex'
import TabSwitch from '../../Elements/TabSwitch'

export default {
  components: { TabSwitch },
  props: {
    hasSimulatedPath: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    menuButtons() {
      return [
        {
          label: 'mylives.submenu.profile',
          title: 'mylives.submenu.profile_title',
          id: 'intro-my-life-my-profile',
          to: { name: 'myProfile' }
        },
        {
          label: 'mylives.submenu.my_people',
          title: 'mylives.submenu.my_people_title',
          activeColor: 'secondary',
          to: { name: 'myPeople' },
          id: "intro-my-life-my-people",
          tooltip: {
            position: 'bottom left',
            name: "lifeStories",
            icons: ["mdi-text-box-outline"],
            title: this.$i18n.t('tooltips.life_stories_title'),
            description: this.$i18n.t('tooltips.life_stories_description')
          }
        },
        {
          label: 'mylives.submenu.invitations',
          id: "intro-my-life-my-invitations",
          title: 'mylives.submenu.invitation_title',
          badge: this.receivedInvitations,
          to: { name: 'myInvitations' }
        },
        {
          id: "intro-my-life-my-vault",
          label: 'mylives.submenu.my_vault',
          title: 'mylives.submenu.my_vault_title',
          to: { name: 'MyVault' }
        }
      ]
    },
    ...mapState({
      receivedInvitations: state => state.invitations.receivedInvitations.length
    }),
  },
  created() {
    this.getAllInvitations({ id: this.currentUser.familyId, params: this.getShowcaseOptions() })
  },
  methods: { ...mapActions('invitations', ['getAllInvitations']),
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
        result.showcase = true
      }

      return result
    },
  }
}
</script>
