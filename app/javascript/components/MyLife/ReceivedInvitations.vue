<template>
  <PeopleCollapse
    :collection="receivedInvitations"
    :collection-limit="6"
    :show-more-limit="6"
    accent="orange"
    wrapper-class="py-0"
    :title="$i18n.t('mylives.invitations.received_invitations')"
    class="mb-10"
    #default="{ collection }"
  >
    <div
      v-if="
        !receivedInvitations.length && !isPageVisited && notificationVisible
      "
      class="notification__box px-5 py-6"
      :class="notificationVisible ? 'close' : ''"
    >
      <div class="notification__mark" />
      <h3 class="d-flex flex-row mb-2">
        <span class="notification__title">{{
          $i18n.t("mylives.invitations.received_invitations_tooltip.title")
        }}</span>
        <v-icon
          class="notification__exit ml-auto mr-0"
          @click="notificationVisible = !notificationVisible"
        >
          mdi-close
        </v-icon>
      </h3>
      <p class="notification__content">
        {{ $i18n.t("mylives.invitations.received_invitations_tooltip.content_text") }}
      </p>
    </div>

    <TileView
      v-else-if="receivedInvitations.length"
      :receivedInvitations="collection"
    />

    <v-row v-else class="d-flex justify-center mt-15">
      <p class="empty-state__description">
        {{ $i18n.t("mylives.invitations.received_empty_state") }}
      </p>
    </v-row>
  </PeopleCollapse>
</template>
<script>
import { mapState } from "vuex"

import TileView from "@/components/MyLife/TileView"
import PeopleCollapse from "@/components/MyPeople/PeopleCollapse"
export default {
  components: {
    TileView,
    PeopleCollapse
  },
  props: {
    isPageVisited: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      notificationVisible: true,
    };
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      receivedInvitations: state => state.invitations.receivedInvitations
    }),
  },
};
</script>
<style lang="scss" scoped>
.notification {
  &__box {
    position: relative;
    width: 478px;
    height: 114px;
    left: 30px;
    top: 15px;
    background: $color-secondary-lightest;
    border-radius: 5px;
  }
  &__mark {
    position: absolute;
    width: 18px;
    height: 18px;
    top: -9px;
    left: 18px;
    background: $color-secondary-lightest;
    transform: rotate(60deg) skewX(30deg);
  }
  &__title {
    font-family: $title-font;
    font-weight: bold;
    font-size: 18px;
    line-height: 23px;
    color: $color-tertiary;
  }
  &__exit {
    width: 14px;
    height: 13px;
    color: $color-tertiary;
    background: $color-secondary-lightest !important;
  }
  &__content {
    top: 50px;
    left: 35px;
    font-family: $body-font-family;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;
    color: $color-tertiary;
  }
}
.empty-state__description {
  font-family: Enriqueta;
  font-size: 22px;
  line-height: 34px;
  color: $color-tertiary;
}
</style>
