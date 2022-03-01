<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mx-md-16 my-12">
        <h2 class="invitation__heading text-center">
          {{ $i18n.t('welcome.existing_profile', { inviterName: senderName, communityName: familyName, communityType: community.type }) }}
        </h2>
        <v-img
          class="mx-auto mt-13"
          height="140"
          width="140"
          :src="invitationImage"
          aspect-ratio="1"
          contain
        />
        <p class="invitation__message text-center mt-12 mx-md-16">
          "{{ message }}"
        </p>
      </div>
    </template>
    <template v-slot:actions>
      <v-btn
          x-large
          rounded
          color="primary"
          outlined
          elevation="0"
          class="ma-1"
          @click="reject"
      >
        {{ $i18n.t('welcome.reject') }}
      </v-btn>
      <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1"
          @click="accept"
      >
        {{ $i18n.t('welcome.accept') }}
      </v-btn>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'

export default {
  components: {
    DialogContent
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      invitation: state => state.families.invitation,
      community: state => state.families.community,
    }),
    senderName() {
      return this.invitation.attributes?.senderName
    },
    familyName() {
      return this.invitation.attributes?.familyName
    },
    message() {
      return this.invitation.attributes?.message
    },
    invitationImage() {
      return this.invitation.attributes?.familyCoverUrl
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog',
      acceptInvitation: 'families/acceptInvitation',
      cancelInvitations: 'families/cancelInvitations',
      setError: 'layout/setError',
    }),
    accept() {
      this.isLoading = true
      const params = {
        invitationId: this.invitation.id,
        payload: {
          invitation: {
            nickname: this.currentUser.name
          }
        }
      }
      this.acceptInvitation(params)
          .then(() => {
            this.closeDialog()
            this.$router.push({ name: 'communities' })
          })
          .catch((error) => {
            this.setError(error)
          })
    },
    reject() {
      try {
        this.cancelInvitations([this.invitation.id])
      } catch (error) {
        this.setError(error)
      } finally {
        this.closeDialog()
      }
    }
  }
}
</script>
<style lang="scss" scoped>
.invitation {
  &__heading {
    font-family: Lato;
    font-weight: bold;
    font-size: 20px;
    line-height: 24px;
    letter-spacing: -0.02em;
    color: $color-tertiary;
  }
  &__message {
    font-family: Lato;
    font-size: 18px;
    line-height: 26px;
    text-align: center;
    color: $color-text;
  }
}
</style>
