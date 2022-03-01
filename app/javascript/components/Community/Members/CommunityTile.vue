<template>
  <a
    class="member mt-13"
    :class="isInvitation ? 'member--invitation' : ''"
    :title="tileTitle"
    @click="click"
  >
    <v-row class="member__avatar d-flex justify-center">
      <Avatar
        size="big"
        :src="member.avatarUrl"
        :outlined="isAdmin(member.userType)"
      />

      <CommunityMemberOptions
        class="member__more"
        :member="member"
        v-if="(!isAdmin(member.userType) && isCurrentUserAdmin) || isInvitation"
      />

      <v-btn
        v-if="!isCurrentUser && isActiveUser"
        class="member__mail"
        :title="$i18n.t('communities.members.send_message')"
        fab
        outlined
        small
        color="primary"
        elevation="0"
      >
        <v-icon>mdi-email-outline</v-icon>
      </v-btn>
    </v-row>
    <v-row class="d-flex justify-center pt-4">
      <h2 class="member__name">{{ tileTitle }}</h2>
    </v-row>
    <v-row class="d-flex justify-center">
      <div
        class="member__role"
        :title="$i18n.t('families.kinships.connector_title')"
      >
        {{ $i18n.t(`families.member_roles.${userRoleLabel}`) }}
      </div>
    </v-row>
  </a>
</template>
<script>
import Avatar from '../../Elements/Avatar'
import { mapState } from 'vuex'
import CommunityMemberOptions from './CommunityMemberOptions'

export default {
  components: {
    Avatar,
    CommunityMemberOptions
  },
  props: {
    member: {
      type: Object,
      required: true
    },
    isInvitation: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      isCurrentUserAdmin: state => state.user.isAdmin
    }),
    tileTitle() {
      return this.member.nickname || this.member.name || this.member.email
    },
    userRoleLabel() {
      return this.member.userType === 'offline member'
        ? this.member.userType
        : this.member.role
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
    click() {
      if (!this.isInvitation) {
        this.$router.push({ name: 'member', params: { id: this.member.id } })
      }
    },
    isAdmin(userType) {
      return userType === 'admin'
    }
  }
}
</script>
<style lang="scss" scoped>
.member {
  max-width: 200px;
  margin: 0 11px;
  &--invitation {
    cursor: auto;
  }
  &__name {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    text-align: center;
    color: $color-tertiary;
    overflow: hidden;
    text-overflow: ellipsis;
  }
  &__role {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 14px;
    line-height: 180%;
    text-align: center;
    color: $color-tertiary;
  }
  &__avatar {
    position: relative;
  }
  &__mail {
    position: absolute;
    right: -30px;
    bottom: 0;
  }
  &__more {
    position: absolute;
    right: -30px;
    top: 0;
  }
}
</style>
