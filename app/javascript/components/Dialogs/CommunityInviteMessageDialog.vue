<template>
  <DialogContent>
    <template v-slot:content>
      <h2 class="invitation__heading mt-10">
        {{ $i18n.t('communities.inviteDialog.messageHeading') }}
      </h2>
      <p class="invitation__description">
        {{ $i18n.t('communities.inviteDialog.messageDescription') }}
      </p>
      <v-divider/>
      <h2 class="invitation__heading mt-6">
        {{ $i18n.t('communities.inviteDialog.messageSubheading') }}
      </h2>
      <v-textarea
          v-model="message"
          rows="4"
          outlined
          class="invitation__input"
      />
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
            x-large
            rounded
            outlined
            color="primary"
            elevation="0"
            class="ma-1"
            min-width="160px"
            min-height="48px"
            @click="goBack"
        >
          {{ $i18n.t('communities.inviteDialog.back') }}
        </v-btn>
        <v-btn
            x-large
            rounded
            color="primary"
            elevation="0"
            class="ma-1"
            min-width="160px"
            min-height="48px"
            @click="nextStep"
        >
          {{ $i18n.t('communities.inviteDialog.send') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'

export default {
  components: {
    DialogContent,
  },
  data() {
    return {
      payload: {},
      message: this.$i18n.t('communities.inviteDialog.messagePlaceholder'),
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community,
      dialog: state => state.layout.dialog
    }),
  },
  created() {
    this.payload = this.dialog.data.payload
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      sendInvitations: 'families/sendInvitations',
    }),
    async nextStep () {
      try {
        this.payload.message = this.message
        this.payload.users = this.payload.users.map(user => {
          return {
            ...user,
            role: user.role.toLowerCase().replace(/-/g,"_")
          }
        })
        await this.sendInvitations(this.payload)
        this.closeDialog()
        await this.$router.replace({ name: 'invitedMembers', params: { id: this.community.id } })
      } catch (error) {
        this.setSnackbar(error.message, 'error')
      }
    },
    goBack () {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'CommunityInviteRoleDialog',
        size: 'big',
        data: { payload: this.payload },
      })
    },
  }
}
</script>
<style lang="scss" scoped>
.invitation {
  &__heading {
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    color: $color-tertiary;
  }
  &__description {
    font-size: 16px;
    line-height: 19px;
    color: $color-text;
  }
  &__input {
    &::v-deep .v-text-field__slot textarea::placeholder {
      font-size: 16px;
      line-height: 19px;
      color: #C4C4C4;
    }
  }
}
</style>
