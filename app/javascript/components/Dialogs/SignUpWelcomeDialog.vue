<template>
  <DialogContent class="welcome-dialog">
    <template v-slot:content>
      <div class="d-flex flex-column px-13 py-12">
        <h2 class="welcome-dialog__heading">{{ $i18n.t('welcome.title') }}</h2>
        <v-img :src="require('../../assets/images/welcome_icon.svg')" contain height="215px"/>
        <p class="welcome-dialog__content">
          {{ $i18n.t('welcome.explainer1',
            { inviterName: senderName, communityName: familyName }) }}
        </p>
        <p class="welcome-dialog__content">
          {{ $i18n.t('welcome.explainer2',
            { inviterName: senderName, communityName: familyName }) }}
        </p>
        <p class="welcome-dialog__content">
          {{ $i18n.t('welcome.explainer3',
            { inviterName: senderName, communityName: familyName }) }}
        </p>
        <v-btn
            class="mx-auto mt-7"
            x-large
            rounded
            color="primary"
            elevation="0"
            @click="goToProfileSetup"
        >
          {{ $i18n.t('welcome.create_your_profile') }}
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
    DialogContent
  },
  computed: {
    ...mapState({
      invitation: state => state.families.invitation
    }),
    senderName() {
      return this.invitation.attributes?.senderName
    },
    familyName() {
      return this.invitation.attributes?.familyName
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog'
    }),
    goToProfileSetup() {
      this.closeDialog()
      this.setDialog(
          {
            title: this.$i18n.t('welcome.profile_title', {
              communityName: this.invitation.attributes.familyName
            }),
            component: 'SignUpProfileSetupDialog',
            size: 'big'
          }
      )
    },
  }
}
</script>
<style lang="scss" scoped>
.welcome-dialog {
  background: url("../../assets/images/dialogue_background.svg") no-repeat;
  &__heading {
    font-weight: bold;
    font-size: 48px;
    line-height: 64px;
    color: $color-tertiary;
  }
  &__content {
    font-size: 23px;
    line-height: 35px;
    text-align: center;
    color: $color-text;
  }
}
</style>
