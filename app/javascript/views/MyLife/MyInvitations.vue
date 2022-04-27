<template>
  <v-container class="invitations-container mt-12">
    <div class="d-flex flex-row align-end mb-8">
      <h2 class="my-invitations__title">
        {{ $i18n.t("mylives.invitations.title") }}
      </h2>
      <span class="my-invitations__total pl-5">
        {{ $i18n.t("mylives.invitations.total") }}
        <v-icon>mdi-circle-small</v-icon>
        {{ receivedInvitations.length + sentInvitations.length}}
      </span>
    </div>
    <ReceivedInvitations :is-page-visited="Boolean(isPageVisited)" />
    <SentInvitations :is-page-visited="Boolean(isPageVisited)" />
  </v-container>
</template>
<script>
import { mapActions, mapState } from "vuex"

import ReceivedInvitations from "@/components/MyLife/ReceivedInvitations"
import SentInvitations from "@/components/MyLife/SentInvitations"

export default {
  components: {
    ReceivedInvitations,
    SentInvitations
  },
  beforeRouteLeave(to, from, next) {
    this.clearFamilies()
    next()
  },
  data() {
    return {
      isPageVisited: localStorage.getItem("isPageVisited")
    }
  },
  computed: mapState({
    communityId: (state) => state.core.user.familyId,
    receivedInvitations: state => state.invitations.receivedInvitations,
    sentInvitations: state => state.invitations.sentInvitations,
  }),
  created() {
    localStorage.setItem("isPageVisited", "true")
    this.getCommunity({
      id: this.communityId
    })
  },
  methods: {
    ...mapActions('families', ['getCommunity', 'clearFamilies']),
  }
};
</script>
<style lang="scss" scoped>
.invitations-container {
  @include container-grid-size();
}
.my-invitations {
  &__title {
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    color: $color-tertiary;
    @media #{map-get($display-breakpoints, 'md-and-down')} {
      font-size: 23px;
      line-height: 31px;
      letter-spacing: -0.02em;
    }
  }
  &__total {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 23px;
    line-height: 41px;
    color: $color-grey;
    @media #{map-get($display-breakpoints, 'md-and-down')} {
      font-size: 18px;
      line-height: 24px;
    }
  }
}
</style>
