
<script>
import { mapActions, mapState } from 'vuex'

import CommunityInviteMessageDialog from '@/components/Dialogs/CommunityInviteMessageDialog.vue'

export default {
  extends: CommunityInviteMessageDialog,
  computed: {
    ...mapState({
      community: state => state.families.community,
      communityId: (state) => state.core.user.familyId,
    }),
    translations() {
      return {
        messageHeading: this.$i18n.t('mylives.invitations.invite_message_dialog.header'),
        messageDescription: this.$i18n.t('mylives.invitations.invite_message_dialog.subheader'),
        messageSubheading: this.$i18n.t('mylives.invitations.invite_message_dialog.label'),
        placeholder: this.$i18n.t('mylives.invitations.invite_message_dialog.placeholder'),
        message: ""
      }
    }
  },
  methods: {
    ...mapActions({
      sendInvitations: 'invitations/sendInvitations',
    }),
    async nextStep() {
      try {
        this.updatePayload()

        await this.sendInvitations({ communityId: this.communityId, payload: this.payload })
        this.closeDialog()
      } catch (error) {
        console.error(error)
      }
    },
    goBack() {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'MyLifeInviteDialog',
        size: 'big',
        data: { payload: this.payload },
      })
    },
  }
}
</script>
