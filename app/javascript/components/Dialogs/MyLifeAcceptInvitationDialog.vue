<template>
  <DialogContent class="invitation__dialog">
    <template v-slot:content>
      <div class="pt-12 px-6 pb-10 invitation__content">
        <!-- personal title -->
        <h2
          v-if="isPersonal"
          class="invitation__heading text-center"
          v-html="
            $i18n.t('mylives.invitations.accept_dialog.personal_subtitle', {
              member: $$(invitation, 'attributes', 'senderName'),
            })
          "
        ></h2>

        <!-- community title -->
        <h2
          v-else
          class="invitation__heading text-center"
          v-html="
            $i18n.t('mylives.invitations.accept_dialog.community_subtitle', {
              senderName: $$(invitation, 'attributes', 'senderName'),
              familyName: $$(invitation, 'attributes', 'familyName'),
              familyType: $$(invitation, 'attributes', 'familyType'),
            })
          "
        ></h2>

        <div class="mt-13 d-flex justify-center flex-column align-center">
          <BaseAvatar
            size="140"
            :src="invitationImage"
            :rounded="$$(invitation, 'attributes', 'personal') === false"
            contain
          />

          <p class="invitation__message text-center mt-12 mx-md-32">
            {{ $$(invitation, "attributes", "message") }}
          </p>
        </div>
      </div>
    </template>
    <template v-slot:actions>
      <v-btn
        x-large
        rounded
        width="160px"
        :color="isPersonal ? 'secondary' : 'primary'"
        outlined
        elevation="0"
        class="ma-1"
        @click="reject"
      >
        {{ $i18n.t("welcome.reject") }}
      </v-btn>
      <v-btn
        x-large
        rounded
        width="160px"
        :color="isPersonal ? 'secondary' : 'primary'"
        elevation="0"
        class="ma-1"
        @click="accept"
      >
        {{ $i18n.t("welcome.accept") }}
      </v-btn>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import BaseAvatar from "@/components/Elements/Avatar"
import DialogContent from '@/components/Layout/Dialog/DialogContent'

export default {
  components: {
    DialogContent,
    BaseAvatar
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      invitation: state => state.families.invitation
    }),
    isPersonal() {
      return this.invitation?.attributes?.personal
    },
    invitationImage() {
      return this.invitation?.attributes?.familyCoverUrl
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      getAllInvitations: 'invitations/getAllInvitations',
      closeDialog: 'layout/closeDialog',
      acceptInvitation: 'families/acceptInvitation',
      cancelInvitations: 'families/cancelInvitations',
      setError: 'layout/setError',
    }),
    async accept() {
      try {
        this.isLoading = true
        const params = {
          invitationId: this.invitation.id,
          payload: {
            invitation: {
              nickname: this.currentUser.name
            }
          }
        }

        if (this.isPersonal) {
          await this.acceptInvitation(params)

          this.closeDialog()
          // get invitations to update badge, fetch only here ,
          //  because communities is out of scope for this menu bar
          this.getAllInvitations({id:this.currentUser.familyId})

          this.$router.push({
            name: "myPeoplePersonProfile",
            params: {
              id: this.invitation.attributes.senderKinshipId
            }
          })
        } else {
          this.goToProfileSetup()

          this.$router.push({
            name: "showFamily",
            params: { id: this.invitation.attributes.familyId }
          })
        }
      } catch (error) {
        this.setError(error)
      }
    },
    reject() {
      try {
        this.cancelInvitations([this.invitation.id])
      } catch (error) {
        this.setError(error)
      } finally {
        this.closeDialog()
      }
    },
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
<style lang="scss">
.invitation {
  &__dialog .dialog-content {
    position: relative;
    overflow: hidden;
    padding: 0px 0px 20px 0px !important;

    &:before {
      @include pseudo($height: 80px);
      background-color: $color-lightest_purple;
      background: url("../../assets/images/dialog-background.svg");
      background-repeat: no-repeat;
      background-size: contain;
      bottom: 0px;
      left: 0;
      z-index: 1;
    }
  }

  &__dialog .dialog-header,
  &__dialog &__content {
    background-color: $color-lightest_purple;
  }

  &__content {
    position: relative;
    z-index: 2;
  }

  &__heading {
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 20px;
    line-height: 24px;
    letter-spacing: -0.02em;
    color: #4b4b4b;
  }
  &__message {
    max-width: 732px;
    font-family: Lato;
    font-size: 18px;
    line-height: 26px;
    text-align: center;
    color: $color-text;
  }
}
</style>
