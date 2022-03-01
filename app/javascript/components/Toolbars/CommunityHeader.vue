<template>
  <v-row class="align-center">
    <v-col cols="3" class="d-flex flex-row align-center">
      <BackButton v-if="isMobile"/>
      <CommunityBreadcrumbs
          v-else
          :community="community"
          :is-edit-mode="isEditMode"
      />
    </v-col>
    <v-col cols="6" class="d-flex flex-row align-center justify-center fill-height">
      <CommunityTabDropdown v-if="isMobile"/>
      <CommunityMenu
        v-else
        :community-id="communityId"
      />
    </v-col>
    <v-col v-if="isMembersOrInvitations" cols="3" class="d-flex flex-row align-center justify-end fill-height">
      <SelectViewType
          :viewType="viewType"
          @setViewType="setViewType"
      />
    </v-col>
    <v-col v-else cols="3" class="d-flex flex-row align-center justify-end fill-height">
      <v-btn
          v-if="isEditable"
          class="ml-1"
          :fab="isMobile"
          :small="isMobile"
          rounded
          outlined
          color="primary"
          elevation="0"
          :title="$i18n.t('families.edit_title')"
          :to="`/communities/${communityId}/edit`"
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
          :to="`/communities/${communityId}`"
      >
        {{ community.isChanged ? $i18n.t('communities.edit.save') : $i18n.t("communities.edit.cancel") }}
      </v-btn>
      <CommunityButtonsDropdown v-if="!isEditMode"/>
    </v-col>
  </v-row>
</template>

<script>
import CommunityMenu from './Community/CommunityMenu'
import CommunityBreadcrumbs from './Communities/CommunityBreadcrumbs'
import { mapActions, mapState } from "vuex";
import breakpointsMixin from "../../mixins/breakpointsMixin";
import CommunityTabDropdown from "./Community/CommunityTabDropdown";
import CommunityButtonsDropdown from "./Community/CommunityButtonsDropdown";
import BackButton from "./Community/BackButton";
import SelectViewType from "../Elements/SelectViewType";

export default {
  components: {
    SelectViewType,
    BackButton,
    CommunityButtonsDropdown,
    CommunityTabDropdown,
    CommunityMenu,
    CommunityBreadcrumbs
  },
  mixins: [
    breakpointsMixin
  ],
  computed: {
    ...mapState({
      community: state => state.families.community,
      viewType: state => state.members.viewType,
    }),
    communityId() {
      return this.$route.params.id
    },
    isEditMode() {
      return this.$route.name === 'community'
    },
    communityCanEdit() {
      return this.$possible('manage', 'Family', { id: this.community.id })
    },
    isEditable() {
      return this.communityCanEdit && !this.isEditMode
    },
    isMembersOrInvitations() {
      return this.$route.name === 'members' || this.$route.name === 'invitedMembers'
    },
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      setViewType: 'members/setViewType',
    }),
    openDeleteCommunityDialog() {
      this.setDialog({
        component: 'CommunityDeleteDialog',
        title: this.$i18n.t('confirmation_dialog.title')
      })
    },
    openInviteToCommunityDialog() {
      this.setDialog({
        component: 'CommunityInviteDialog',
        title: this.$i18n.t('invitations.family_member.title')
      })
    }
  }
}
</script>
