<template>
  <v-row>
    <v-col cols="3" md="4" class="d-flex flex-row align-center justify-start">
      <BackButton v-if="isMobile && member.name"/>
      <CommunityBreadcrumbs
          v-else
          :community="member.community"
          :member-name="member.name"
      />
    </v-col>
    <v-col cols="6" md="4" class="d-flex flex-row align-center justify-center">
      <CommunityTabDropdown v-if="isMobile" :community-id="communityId" simulatePath="members" />
      <TabSwitch v-else :buttons="menuButtons" simulatePath="members" />
    </v-col>
    <v-col cols="3" md="4" class="d-flex flex-row align-center justify-end fill-height">
      <v-btn
        v-if="!isEditMode && canManageKinship"
        class="ml-1"
        :fab="isMobile"
        :small="isMobile"
        rounded
        outlined
        color="primary"
        elevation="0"
        :title="$i18n.t('families.edit_title')"
        :to="`/communities/members/${member.id}/edit`"
      >
        <v-icon :left="!isMobile">mdi-pencil</v-icon>
        <span v-if="!isMobile">
          {{ $i18n.t('families.edit') }}
        </span>
      </v-btn>
      <v-btn
        v-if="isEditMode"
        class="ml-1"
        rounded
        outlined
        color="primary"
        elevation="0"
        :title="$i18n.t('families.edit_title')"
        :to="`/communities/members/${member.id}`"
      >
        {{ $i18n.t('communities.edit.save')  }}
      </v-btn>
      <CommunityMemberOptions
        v-if="isDisplayMemberOptions"
        class="ml-1"
        :member="member"
        theme="toolbar"
      />
    </v-col>
  </v-row>
</template>

<script>
import TabSwitch from '../Elements/TabSwitch'
import { mapState } from "vuex";
import breakpointsMixin from "../../mixins/breakpointsMixin";
import CommunityBreadcrumbs from "./Communities/CommunityBreadcrumbs";
import CommunityTabDropdown from "./Community/CommunityTabDropdown";
import CommunityMemberOptions from '../Community/Members/CommunityMemberOptions'
import BackButton from "@/components/Toolbars/Community/BackButton";

export default {
  components: {
    CommunityBreadcrumbs,
    TabSwitch,
    CommunityTabDropdown,
    CommunityMemberOptions,
    BackButton,
  },
  mixins: [
    breakpointsMixin
  ],
  data: () => ({
    kinship: null,
  }),
  computed: {
    ...mapState({
      currentUser: store => store.core.user,
      member: store => store.members.member,
      community: state => state.families.community
    }),
    communityId() {
      return this.member.familyId
    },
    isCurrentUserConnector() {
      return this.member?.isCurrentUserConnector
    },
    isCurrentUserAdmin() {
      return this.community.isAdmin
    },
    isDisplayMemberOptions() {
      return this.isCurrentUserAdmin && !this.isCurrentUserConnector
    },
    isEditMode() {
      return this.$route.name === 'memberEdit'
    },
    canManageKinship() {
      return this.$possible('manage', 'Kinship', {
        userId: this.member.userId, familyId: this.member.familyId, accessType: this.member.accessType
      })
    },
    menuButtons() {
      return [
        {
          label: 'families.submenu.profile',
          title: 'families.submenu.profile_title',
          to: { name: 'showFamily', params: { id: this.communityId } }
        },
        {
          label: 'families.submenu.members',
          title: 'families.submenu.members_title',
          to: { name: 'members', params: { id: this.communityId } }
        },
        {
          label: 'families.submenu.invited_members',
          title: 'families.submenu.invited_members_title',
          to: { name: 'invitedMembers', params: { id: this.communityId } }
        },
        {
          label: 'families.submenu.vault',
          title: 'families.submenu.vault_title',
          to: { name: 'communityVault', params: { id: this.communityId } }
        }
      ]
    },
    memberOptions() {
      return [
        {
          id: 'changeMemberRole',
          title: this.$i18n.t('families.member_options_change_role'),
          action: 'toggleEditRole'
        },
        {
          id: 'removeMember',
          title: this.$i18n.t('families.member_options_remove'),
          action: 'toggleRemoveMember'
        }
      ]
    }
  },
}
</script>
