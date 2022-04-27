<script>
import { mapState } from 'vuex'
import CommunityInviteDialog from "@/components/Dialogs/CommunityInviteDialog.vue"
export default {
  name: "MyLifeInviteDialog",
  extends: CommunityInviteDialog,
  computed: {
    ...mapState({
      community: state => state.families.community
    }),
    translations() {
      return {
        emailInvitationHeading: this.$i18n.t('mylives.invitations.invite_dialog.via_email'),
        emailInvitationDescription: this.$i18n.t('mylives.invitations.invite_dialog.email_subheader'),
        memberInvitationHeading: this.$i18n.t('mylives.invitations.invite_dialog.via_kinscape'),
        memberInvitationDescription: this.$i18n.t('mylives.invitations.invite_dialog.kinscape_subheader')
      }
    },
  },
  methods: {
    async nextStep() {
      await this.setDialog({
        title: this.$i18n.t('mylives.invitations.invite_dialog.title'),
        component: 'MyLifeInviteMessageDialog',
        size: 'big',
        data: { payload: this.getPayload() },
      })
    }
  }
}
</script>