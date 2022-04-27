<template>
  <DialogContent
    class="welcome-dialog"
    :class="`welcome-dialog--step${step}`"
  >
    <template
      v-if="step === 1"
      #content
    >
      <div class="secondary_dark--text text-h3 font-story text-left">
        {{ $i18n.t('account.onboarding_dialog.title') }}
      </div>
      <v-img
        class="mx-auto"
        height="280"
        contain
        :src="require('../../assets/images/welcome_dlg_img.svg')"
      />

      <div
        v-if="currentUser.registrationMethod === 'member'"
        v-html="$i18n.t(
          'account.onboarding_dialog.welcome_member',
          {
            inviterName,
            communityName,
            communityType
          }
        )"
        class="subtitle-1 mb-4"
      />
      <div
        v-else-if="currentUser.registrationMethod === 'follower'"
        v-html="$i18n.t(
          'account.onboarding_dialog.welcome_follower',
          { inviterName }
        )"
        class="subtitle-1 mb-4"
      />
      <div
        v-else-if="currentUser.registrationMethod === 'offline'"
        v-html="$i18n.t(
          'account.onboarding_dialog.welcome_offline',
          { inviterName }
        )"
        class="subtitle-1 mb-4"
      />
      <div
        v-else
        v-html="$i18n.t('account.onboarding_dialog.welcome_direct')"
        class="subtitle-1 mb-4"
      />

      <div class="secondary_dark--text text-h6 font-story mb-4">
        {{ $i18n.t('account.onboarding_dialog.welcome_message') }}
      </div>

      <v-btn
        class="welcome-dialog__next subtitle-1 elevation-0 mb-6"
        color="primary"
        rounded
        x-large
        @click="goToNext"
      >
        {{ $i18n.t('account.onboarding_dialog.action_next') }}
      </v-btn>
      <br>
      <a
        class="subtitle-1"
        @click="setupProfile"
      >
        {{ $i18n.t('account.onboarding_dialog.action_skip') }}
      </a>
    </template>

    <template
      v-else-if="step === 2"
      #content
    >
      <v-img
        class="mx-auto mb-12"
        contain
        :src="require('../../assets/images/logo-large.svg')"
        width="173"
        height="35"
      />
      <div class="welcome-dialog__contents">
        <v-img
          class="welcome-dialog__img"
          contain
          :src="require('../../assets/images/welcome__step2.png')"
          width="400"
          height="380"
        />

        <div class="flex-grow-1 align-self-center">
          <div class="welcome-dialog__topic font-story mb-2">
            {{ $i18n.t('account.onboarding_dialog.step2.title') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step2.subtitle') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step2.create') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step2.create_text') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step2.invite') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step2.invite_text') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step2.share') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step2.share_text') }}
          </div>
        </div>
      </div>

      <div class="welcome-dialog__actions">
        <v-btn
          class="welcome-dialog__back subtitle-1 elevation-0 mr-5"
          color="primary"
          rounded
          x-large
          outlined
          @click="goToBack"
        >
          {{ $i18n.t('account.onboarding_dialog.action_back') }}
        </v-btn>
        <v-btn
          class="welcome-dialog__next subtitle-1 elevation-0"
          color="primary"
          rounded
          x-large
          @click="goToNext"
        >
          {{ $i18n.t('account.onboarding_dialog.action_next') }}
        </v-btn>
      </div>
    </template>

    <template
      v-else-if="step === 3"
      #content
    >
      <v-img
        class="mx-auto mb-12"
        contain
        :src="require('../../assets/images/logo-large.svg')"
        width="173"
        height="35"
      />
      <div class="welcome-dialog__contents">
        <v-img
          class="welcome-dialog__img"
          contain
          :src="require('../../assets/images/welcome__step3.png')"
          width="400"
          height="380"
        />

        <div class="flex-grow-1 align-self-center">
          <div class="welcome-dialog__topic font-story mb-8">
            {{ $i18n.t('account.onboarding_dialog.step3.title') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step3.subtitle') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step3.share') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step3.share_text') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step3.control') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step3.control_text') }}
          </div>
        </div>
      </div>

      <div class="welcome-dialog__actions">
        <v-btn
          class="welcome-dialog__back subtitle-1 elevation-0 mr-5"
          color="primary"
          rounded
          x-large
          outlined
          @click="goToBack"
        >
          {{ $i18n.t('account.onboarding_dialog.action_back') }}
        </v-btn>
        <v-btn
          class="welcome-dialog__next subtitle-1 elevation-0"
          color="primary"
          rounded
          x-large
          @click="goToNext"
        >
          {{ $i18n.t('account.onboarding_dialog.action_next') }}
        </v-btn>
      </div>
    </template>

    <template
      v-else-if="step === 4"
      #content
    >
      <v-img
        class="mx-auto mb-12"
        contain
        :src="require('../../assets/images/logo-large.svg')"
        width="173"
        height="35"
      />
      <div class="welcome-dialog__contents">
        <v-img
          class="welcome-dialog__img"
          contain
          :src="require('../../assets/images/welcome__step4.png')"
          width="400"
          height="380"
        />

        <div class="flex-grow-1 align-self-center">
          <div class="welcome-dialog__topic font-story mb-2">
            {{ $i18n.t('account.onboarding_dialog.step4.title') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step4.subtitle') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step4.stories') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step4.stories_text') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step4.profile') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step4.profile_text') }}
          </div>

          <div class="welcome-dialog__content-text font-weight-bold">
            {{ $i18n.t('account.onboarding_dialog.step4.invite') }}
          </div>
          <div class="welcome-dialog__content-text mb-12">
            {{ $i18n.t('account.onboarding_dialog.step4.invite_text') }}
          </div>
        </div>
      </div>

      <div class="welcome-dialog__actions">
        <v-btn
          class="welcome-dialog__back subtitle-1 elevation-0 mr-5"
          color="primary"
          rounded
          x-large
          outlined
          @click="goToBack"
        >
          {{ $i18n.t('account.onboarding_dialog.action_back') }}
        </v-btn>
        <v-btn
          class="welcome-dialog__next subtitle-1 elevation-0"
          color="primary"
          rounded
          x-large
          @click="setupProfile"
        >
          {{ $i18n.t('account.onboarding_dialog.action_setup') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import DialogContent from '@/components/Layout/Dialog/DialogContent'
import kinshipsRepository from '@/repositories/kinships-repository'

export default {
  components: {
    DialogContent
  },
  data: () => ({
    step: 1,
    inviterName: null
  }),
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      families: state => state.families.simpleList.families,
      communities: state => state.families.all,
      followings: state => state.myPeople.followings.data
    }),
    communityName () {
      return this.communities?.[0]?.attributes?.name
    },
    communityType () {
      return this.communities?.[0]?.attributes?.family_type
    }
  },
  watch: {
    families: {
      handler: 'getInviterInfo',
      immediate: true
    },
    followings: {
      handler: 'getInviterInfo',
      immediate: true
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setDialog: 'layout/setDialog'
    }),
    goToBack () {
      this.step--
    },
    goToNext () {
      this.step++
    },
    async getInviterInfo () {
      const familyId = this.families?.[0]?.id || this.followings?.[0]?.attributes?.familyId
      if (!familyId || this.inviterName) {
        return
      }
      const kinship = await kinshipsRepository.getKinshipByFamily(familyId)

      this.inviterName = kinship.data.attributes.invited_by
    },
    setupProfile () {
      switch (this.currentUser.registrationMethod) {
      case 'member':
        this.setDialog({
          title: this.$i18n.t(
            'account.submit_profile.title_community',
            { communityName: this.communityName }
          ),
          component: 'SetupProfile',
          size: 'big',
          persistent: true,
          hideCloseBtn: true
        })
        break;
      case 'follower':
        this.setDialog({
          title: this.$i18n.t('account.submit_profile.title_my_people'),
          component: 'SetupProfile',
          size: 'big',
          persistent: true,
          hideCloseBtn: true
        })
        break;
      case 'offline':
        this.closeDialog()
        break;
      default:
        this.setDialog({
          title: this.$i18n.t('account.submit_profile.title'),
          component: 'SetupProfile',
          size: 'big',
          persistent: true,
          hideCloseBtn: true
        })
        break;
      }
    }
  }
}
</script>

<style lang="scss">
@import '../../../assets/stylesheets/base_styles/_grid-settings.scss';

.welcome-dialog {
  .font-story {
    font-family: Enriqueta !important;
    font-weight: 700;
    line-height: 150%;
  }
  .welcome-dialog__content-text {
    font-size: 18px;
  }

  > .dialog-content {
    padding: 60px 40px !important;
  }

  .welcome-dialog__back,
  .welcome-dialog__next {
    width: 180px;
  }

  &.welcome-dialog--step1 {
    text-align: center;

    > .dialog-content {
      background-size: cover;
      background-position: center;
      background-repeat: no-repeat;
      background-image: url("../../assets/images/welcome_dlg_back.svg");
    }
  }

  .welcome-dialog__contents {
    display: flex;
    flex-direction: row;
    justify-content: space-between;

    .welcome-dialog__topic {
      font-size: 30px;
    }

    .welcome-dialog__img {
      flex: 0 0 auto;
      margin-right: 48px;
      margin-bottom: 32px;
    }
  }

  .welcome-dialog__actions {
    padding-left: 248px;
  }

  @media (max-width: $large-screen) {
    .welcome-dialog__contents {
      flex-direction: column;
      justify-content: flex-start;

      .welcome-dialog__img {
        margin-left: auto;
        margin-right: auto;
      }
    }

    .welcome-dialog__actions {
      padding-left: 0;
      text-align: center;
    }
  }
}
</style>
