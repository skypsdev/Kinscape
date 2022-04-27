<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
        class="mb-12"
        height="320"
        contain
        :src="require('@/assets/images/my-people/empty-state')"
    />
    <p class="empty-state__heading f--tertiary text-center mx-auto">
      {{ $i18n.t('communities.invitation_empty_state.heading') }}
    </p>
    <p class="empty-state__p f--tertiary text-center mx-auto">
      {{ $i18n.t('communities.invitation_empty_state.label') }}
    </p>
    <v-row class="mx-auto">
      <v-col class="col-auto d-flex pl-md-0">
        <v-btn
            v-if="canManageCommunity"
            rounded
            color="primary"
            elevation="0"
            @click="showInviteModal"
        >
          <v-icon class="pr-2">mdi-plus-circle-outline</v-icon>
          <span>
            {{ $i18n.t('communities.members.invite') }}
          </span>
        </v-btn>
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapState, mapActions } from "vuex";

export default {
  computed: {
    ...mapState({
      community: state => state.families.community
    }),
    canManageCommunity() {
      return this.$possible('manage', 'Family', { id: this.community.id })
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    showInviteModal() {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        size: 'big',
        component: 'CommunityInviteDialog',
      })
    },
  }
}
</script>
<style lang="scss" scoped>
.empty-state {
  &__heading {
    font-weight: bold;
    font-size: 32px;
    line-height: 43px;
  }
  &__p {
    max-width: 450px;
    font-family: Lato;
    font-style: normal;
    font-size: 17px;
    line-height: 24px;
    text-align: center;
    color: $color-tertiary;
  }
}
</style>
