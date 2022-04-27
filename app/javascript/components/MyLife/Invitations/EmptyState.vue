<template>
  <v-row class="mt-15">
    <v-row v-if="isPageVisited" class="d-flex justify-center">
      <p class="empty-state__description">
        {{ $i18n.t("mylives.invitations.invite_empty_state") }}
      </p>
    </v-row>
    <v-row v-else>
      <v-col cols="3" class="pt-4">
        <v-img
          :src="require('../../../assets/images/invite-people.svg')"
          height="200px"
          contain
        />
      </v-col>
      <v-col>
        <h2 class="empty-state__title mb-6">
          {{ $i18n.t("mylives.invitations.invite_people") }}
        </h2>
        <p class="empty-state__description mb-6">
          {{ $i18n.t("mylives.invitations.invite_people_desc") }}
        </p>
        <div class="mt-6">
          <v-btn class="empty-state__secondary-button" @click="inviteFn">
            <v-icon size="20" class="mr-2" color="white"
              >mdi-plus-circle-outline</v-icon
            >
            {{ $i18n.t("mylives.invitations.invite_people") }}
          </v-btn>
        </div>
      </v-col>
    </v-row>
  </v-row>
</template>
<script>
export default {
  name: 'InvitationsEmptyState',
  props: {
    inviteFn: {
      type: Function,
      default: null,
      required: true
    },
    isPageVisited: {
      type: Boolean,
      required: true
    }
  },
}
</script>
<style lang="scss" scoped>
.empty-state {
  &__title {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: bold;
    font-size: 32px;
    line-height: 43px;
    color: $color-tertiary;
  }
  &__description {
    font-family: Enriqueta;
    font-size: 22px;
    line-height: 34px;
    color: $color-tertiary;
  }
  &__secondary-button {
    padding: 18px 10px !important;
    border: 1px solid #8b78fe;
    box-sizing: border-box;
    border-radius: 24px;
    box-shadow: none;
    background-color: #8b78fe !important;
    color: white !important;
  }
}
</style>
