<template>
  <DialogContent>
    <template v-slot:content>
      <h2 class="invitation__heading mt-10">
        {{ translations.messageHeading }}
      </h2>
      <p class="invitation__description">
        {{ translations.messageDescription }}
      </p>
      <v-divider />
      <h2 class="invitation__heading mt-6">
        {{ translations.messageSubheading }}
      </h2>
      <v-textarea
        v-model="message"
        rows="4"
        outlined
        :placeholder="translations.placeholder"
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
          {{ $i18n.t("communities.inviteDialog.back") }}
        </v-btn>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1 invitation-sent-cvr-btn"
          min-width="160px"
          min-height="48px"
          @click="nextStep"
        >
          {{ $i18n.t("communities.inviteDialog.send") }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import { mapActions, mapState } from 'vuex'
import { cloneDeep as _cloneDeep } from 'lodash'

import DialogContent from '@/components/Layout/Dialog/DialogContent'

export default {
  components: {
    DialogContent,
  },
  data() {
    return {
      payload: {},
      message: '',
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community,
      dialog: state => state.layout.dialog
    }),
    translations() {
      return {
        messageHeading: this.$i18n.t('communities.inviteDialog.messageHeading'),
        messageDescription: this.$i18n.t('communities.inviteDialog.messageDescription'),
        messageSubheading: this.$i18n.t('communities.inviteDialog.messageSubheading'),
        placeholder: '',
        message: this.$i18n.t('communities.inviteDialog.messagePlaceholder')
      }
    }
  },
  created() {
    this.payload = _cloneDeep(this.dialog.data.payload)
    this.message = this.translations.message
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      sendInvitations: 'families/sendInvitations',
    }),
    updatePayload() {
      this.$set(this.payload, 'message', this.message)

      const users = this.payload.users.map(user => ({
        ...user,
        role: user.role.toLowerCase().replace(/-/g, "_")
      }))
      this.$set(this.payload, 'users', users)
    },
    async nextStep() {
      try {
        this.updatePayload()
        await this.sendInvitations(this.payload)
        this.closeDialog()
        await this.$router.replace({ name: 'invitedMembers', params: { id: this.community.id } })
      } catch (error) {
        if (!error.message.includes('Avoided redundant navigation to current location')) {
          this.setSnackbar(error.message, 'error')
        }
      }
    },
    goBack() {
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
      color: #c4c4c4;
    }
  }
}

</style>
