<template>
  <div class="pl-4 pt-8">
    <v-row class="w--100">
      <v-col
        v-for="(invitation, index) in receivedInvitations"
        :key="`top-${invitation.id}-${index}`"
        cols="12"
        lg="4"
        md="4"
        sm="6"
        xs="12"
      >
        <!-- personal card -->
        <v-card
          v-if="invitation.attributes.personal"
          class="h-100 rounded-lg"
          color="#f7f7f7"
          elevation="0"
        >
          <v-card-text>
            <v-container>
              <v-row>
                <v-col cols="12" class="flex flex-row pa-0">
                  <BaseAvatar
                    size="medium"
                    contain
                    :src="invitation.attributes.family_cover_url"
                    class="mr-5"
                  />
                  <span class="invitation-card invitation-card__people">
                    {{ $i18n.t("mylives.invitations.my_people") }}
                  </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="text-justify d-flex flex-column pa-0">
                  <span class="pa-2" outlined tile>
                    {{ $i18n.t("mylives.invitations.invited_by") }}
                    <b> {{ invitation.attributes.sender_name }} </b> to follow
                    their <b>Personal Stories</b>
                  </span>
                  <span>
                    {{
                      $moment(invitation.attributes.created_at).format(
                        "Do MMM YYYY"
                      )
                    }}
                  </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="pa-0">
                  <v-btn
                    rounded
                    class="form-button float-right"
                    outlined
                    small
                    :disabled="isLoading"
                    min-height="32px"
                    color="secondary"
                    elevation="0"
                    @click="showJoinDialog(invitation)"
                  >
                    {{ $i18n.t("mylives.invitations.view_invitations") }}
                  </v-btn>
                </v-col>
              </v-row>
            </v-container>
          </v-card-text>
        </v-card>

        <!-- community card -->
        <v-card v-else class="h-100 rounded-lg" color="#f7f7f7" elevation="0">
          <v-card-text>
            <v-container>
              <v-row>
                <v-col cols="12" class="pa-0">
                  <BaseAvatar
                    size="medium"
                    rounded
                    contain
                    :src="invitation.attributes.family_cover_url"
                    class="mr-5"
                  />
                  <span class="invitation-card invitation-card__community">
                    {{ invitation.attributes.family_type }}
                  </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="text-justify d-flex flex-column pa-0">
                  <span class="pa-2" outlined tile>
                    {{ $i18n.t("mylives.invitations.join_invite") }}
                    <strong>
                      {{
                        `"${invitation.attributes.family_name}" ${invitation.attributes.family_type}`
                      }}
                    </strong>
                  </span>
                  <span>
                    {{
                      $moment(invitation.attributes.created_at).format(
                        "Do MMM YYYY"
                      )
                    }}
                  </span>
                </v-col>
              </v-row>
              <v-row>
                <v-col cols="12" class="pa-0">
                  <v-btn
                    rounded
                    class="form-button float-right"
                    outlined
                    small
                    :disabled="isLoading"
                    min-height="32px"
                    color="primary"
                    elevation="0"
                    @click="showJoinDialog(invitation)"
                  >
                    {{ $i18n.t("mylives.invitations.view_invitations") }}
                  </v-btn>
                </v-col>
              </v-row>
            </v-container>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </div>
</template>
<script>
import { mapActions } from 'vuex'

import BaseAvatar from "@/components/Elements/Avatar"

import spinnerMixin from '@/mixins/spinnerMixin'
export default {
  components: { BaseAvatar },
  mixins: [spinnerMixin],
  props: {
    receivedInvitations: {
      type: Array,
      required: true
    }
  },
  methods: {
    ...mapActions({
      getInvitation: 'families/getInvitation',
      setDialog: 'layout/setDialog',
      setSnackbar: 'layout/setSnackbar',
    }),
    async showJoinDialog(invitation) {
      try {
        this.onLoading()
        await this.getInvitation(invitation.id)

        const isPersonal = invitation.attributes.personal
        this.setDialog({
          title: isPersonal
              ? this.$i18n.t('mylives.invitations.accept_dialog.personal_title')
              : this.$i18n.t('mylives.invitations.accept_dialog.community_title'),
          component: 'MyLifeAcceptInvitationDialog',
          size: 'big'
        })
      } catch (err) {
        console.error(err)
        this.setSnackbar(err.message)

      } finally {
        this.onLoaded()
      }
    }
  },
};
</script>
<style lang="scss" scoped>
.invitation-card {
  border-radius: 14px;
  padding: 2px 8px;
  margin-top: 10px;
  font-weight: bold;
  font-size: 16px;
  line-height: 180%;
  text-transform: uppercase;
  &__wrapper {
    min-height: 360px;
  }

  &__community {
    color: $color-text;
    background: $color-light-grey;
  }
  &__people {
    background: $color-secondary-lightest;
    color: $secondary-darker;
  }
}
.form-button {
  padding: 0px 25px 0px 25px !important;
}
</style>
