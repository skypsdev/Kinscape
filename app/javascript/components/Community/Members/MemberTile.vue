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
        :outlined="isAdmin"
      />

      <CommunityMemberOptions
        class="member__more"
        :member="member"
        v-if="!isInvitation && !isAdmin && canManageCommunity"
      />

<!--      TODO: use component like CommunityMemberOptions for invitations instead InvitationMenu-->
      <InvitationMenu
        class="member__more"
        :member="member"
        v-if="isInvitation && canManageCommunity"
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
        @click="messageMember"
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
        {{ userRoleLabel }}
      </div>
    </v-row>
  </a>
</template>
<script>
import Avatar from '../../Elements/Avatar'
import { mapState, mapActions } from 'vuex'
import CommunityMemberOptions from './CommunityMemberOptions'
import InvitationMenu from "./InvitationMenu";

export default {
  components: {
    InvitationMenu,
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
      community: state => state.families.community
    }),
    canManageCommunity() {
      return this.$possible('manage', 'Family', { id: this.community.id })
    },
    tileTitle() {
      return this.member.nickname || this.member.name || this.member.email
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
    userRoleLabel() {
      const role = this.$i18n.t(`families.member_roles.${this.member.role}`)
      if (!this.isInvitation) return role
      return this.$i18n.t('families.member_roles.invited_as', { role })
    },
    isAdmin() {
      return this.member.role === 'admin'
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    click() {
      if (!this.isInvitation) {
        this.$router.push({ name: 'member', params: { id: this.member.id } })
      }
    },
    messageMember() {
      this.setDialog({
        component: 'SendMessageToMembersDialog',
        title: this.$i18n.t('requests.title'),
        data: {
          kinshipsIds: [this.member.id.toString()],
          familyId: this.community.id,
          locked: true
        }
      })
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
