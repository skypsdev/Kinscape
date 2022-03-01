<template>
  <v-row class="list-item mb-2 list-item__action">
    <v-col
        class="pa-0 d-flex flex-row"
        :class="isInvitation ? 'list-item--invitation' : ''"
        cols="3"
        @click="goToMember"
    >
      <Avatar
          :src="member.avatarUrl"
          height="32"
          width="32"
          max-width="32"
          class="mx-3 my-auto"
      />
      <p class="list-item__title ma-0">{{ member.nickname || member.name || member.email }}</p>
    </v-col>
    <v-col class="d-flex">
      <p class="list-item__title ma-0">
        {{ transformRoleString(memberRole) }}
      </p>
    </v-col>
    <v-col class="d-flex">
      <p v-if="isInvitation" class="list-item__column-text ma-0">
        {{ member.createdAt ? this.$i18n.l('date.formats.default', member.createdAt) : '-'  }}
      </p>
      <p class="list-item__column-text ma-0" v-else>
        {{ member.createdAt ? this.$i18n.l('date.formats.default', member.createdAt) : '-'  }}
      </p>
    </v-col>
    <v-col class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ member.invitedBy || member.senderName }}
      </p>
    </v-col>
    <v-col cols="3" class="v-list-item__action d-flex pa-0 justify-end">
      <div v-if="isInvitation">
        <v-btn
            rounded
            outlined
            color="primary"
            elevation="0"
            class="mr-2"
            @click="sendResendInvitation"
        >
          {{ $i18n.t('communities.invitations.resend') }}
        </v-btn>
        <v-btn
            rounded
            outlined
            color="primary"
            elevation="0"
            @click="sendCancelInvitation"
        >
          {{ $i18n.t('communities.invitations.cancel_invitation') }}
        </v-btn>
      </div>
      <div v-else class="d-flex flex-row justify-center align-end">
        <v-btn
            v-if="!isCurrentUser && isActiveUser"
            class="mr-7"
            :title="$i18n.t('communities.members.send_message')"
            fab
            outlined
            small
            color="primary"
            elevation="0"
        >
          <v-icon>mdi-email-outline</v-icon>
        </v-btn>
        <CommunityMemberOptions
            class="mr-7"
            :member="member"
            v-if="(isActiveUser && !isAdmin(member.userType) && isCurrentUserAdmin) || isInvitation"
        />
      </div>
    </v-col>
  </v-row>
</template>

<script>
import Avatar from "../../Elements/Avatar";
import { mapActions, mapState } from "vuex";
import CommunityMemberOptions from "./CommunityMemberOptions";

export default {
  components: { CommunityMemberOptions, Avatar },
  props: {
    member: {
      type: Object,
      required: true
    },
    isInvitation: {
      type: Boolean,
      default: false
    },
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      isCurrentUserAdmin: state => state.user.isAdmin
    }),
    memberRole () {
      return this.member.role
    },
    isCurrentUserAdmin() {
      return this.member.isCurrentUserConnector
    },
    isActiveUser() {
      return !!this.member.userId
    },
    isCurrentUser() {
      if (this.isActiveUser) {
        return this.member.userId.toString() === this.currentUser.id.toString()
      } else {
        return false
      }
    },
  },
  methods: {
    ...mapActions({
      resendInvitations: 'families/resendInvitations',
      cancelInvitations: 'families/cancelInvitations'
    }),
    sendResendInvitation() {
      this.resendInvitations([this.member.id])
    },
    sendCancelInvitation() {
      this.cancelInvitations([this.member.id])
    },
    goToMember() {
      if (!this.isInvitation) {
        this.$router.push({
          name: 'member',
          params: { id: this.member.id }
        })
      }
    },
    transformRoleString(string) {
      return string.charAt(0).toUpperCase() + string.slice(1).split('_').join('-');
    },
    isAdmin(userType) {
      return userType === 'admin'
    },
  }
}
</script>

<style scoped lang="scss">
.list-item {
  background: $color-dark-white;
  border-radius: 5px;
  &--invitation {
    cursor: auto;
  }
  &__action {
    cursor: pointer;
  }
  &__title {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-weight: bold;
    font-size: 16px;
    line-height: 16px;
  }
  &__column-text {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;
  }
}

</style>
