<template>
  <DialogContent>
    <template v-slot:content>
      <v-col class="py-0 mt-11">
        <h2 class="invitation__heading">
          {{ translations.emailInvitationHeading }}
        </h2>
        <p class="invitation__description mt-1">
          {{ translations.emailInvitationDescription }}
        </p>
      </v-col>

      <v-col class="py-0 mb-6">
        <EmailPicker
          class="mt-7"
          v-model="emails"
          @validate="setEmailValidation"
        />
      </v-col>

      <v-divider class="mx-3" />
      <v-col class="py-0">
        <h2 class="invitation__heading mt-6">
          {{ translations.memberInvitationHeading }}
        </h2>
        <p class="invitation__description mt-1">
          {{ translations.memberInvitationDescription }}
        </p>
      </v-col>

      <v-col cols="12" md="4">
        <Search :search-term="searchTerm" @setSearch="setSearch" />
      </v-col>
      <v-col>
        <ToggleSelect v-model="selectedMembers" :items="membersFiltered" />
      </v-col>
    </template>

    <template v-slot:actions>
      <div>
        <v-btn
          x-large
          rounded
          outlined
          color="primary"
          elevation="0"
          class="ma-1"
          min-width="160px"
          min-height="48px"
          @click="closeDialog"
        >
          {{ $i18n.t("communities.inviteDialog.cancel") }}
        </v-btn>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1"
          min-width="160px"
          min-height="48px"
          @click="nextStep"
          :disabled="!isFormValid"
        >
          {{ $i18n.t("communities.inviteDialog.next") }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import { mapActions, mapState } from 'vuex'
import { groupBy as _groupBy, pick as _pick } from "lodash"

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import Search from "@/components/Elements/Forms/Search";
import ToggleSelect from "@/components/Elements/Forms/ToggleSelect";
import EmailPicker from "@/components/Elements/Forms/EmailPicker";

export default {
  components: {
    EmailPicker,
    ToggleSelect,
    DialogContent,
    Search
  },
  data() {
    return {
      emails: [],
      selectedMembers: [],
      searchTerm: '',
      areAllEmailsValid: false,
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community,
      familyMembers: state => state.families.simpleList.members,
      currentUser: state => state.core.user,
      dialog: state => state.layout.dialog
    }),
    translations() {
      return {
        emailInvitationHeading: this.$i18n.t('communities.inviteDialog.emailInvitationHeading'),
        emailInvitationDescription: this.$i18n.t('communities.inviteDialog.emailInvitationDescription'),
        memberInvitationHeading: this.$i18n.t('communities.inviteDialog.memberInvitationHeading'),
        memberInvitationDescription: this.$i18n.t('communities.inviteDialog.memberInvitationDescription')
      }
    },
    allMembers() {
      // members without current user
      const members = this.familyMembers.filter(({ attributes }) => {
        return attributes.userId != this.currentUser.id
      })

      const transformedMembers = members.map(item => {
        return {
          id: item.attributes.userId,
          image: item.attributes.avatarUrl,
          name: item.attributes.nickname,
        }
      })

      const membersGroupedByUserId = _groupBy(transformedMembers, val => val.id)

      // each group of members will have multiple occurrences, should pick only one from each group
      return Object.keys(membersGroupedByUserId).map(id => {
        const membersGroup = membersGroupedByUserId[id]
        return membersGroup.find(member => member.image !== null) || membersGroup[0]
      })
    },
    membersFiltered() {
      const search = this.searchTerm.toLowerCase()

      return this.allMembers.filter(item => {
        if (!item.id) return false
        const text = item.name.toLowerCase()
        const isNotInCommunity = !this.community.usersIds.includes(item.id)

        return text.indexOf(search) > -1 && isNotInCommunity
      })
    },
    hasSelectedMembers() {
      return this.selectedMembers.length > 0
    },
    hasEmails() {
      return this.emails.length > 0
    },
    isFormValid() {
      return this.hasSelectedMembers || (this.hasEmails && this.areAllEmailsValid)
    }
  },
  watch: {
    selectedMembers() {
      this.search = ''
    },
  },
  created() {
    if (this.dialog.data?.payload) {
      this.emails = this.dialog.data.payload.users
        .filter((val) => val.email)
        .map(item => item.email)

      this.selectedMembers = this.dialog.data.payload.users
        .filter((val) => val.name)
        .map(item => _pick(item, ['id', 'name']))
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      fetchFamily: 'families/findRecord',
      setDialog: 'layout/setDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
    }),
    getPayload() {
      return {
        users: [
          ...this.emails.map((email) => ({
            email: email,
            role: 'Member',
          })),

          ...this.selectedMembers.map((member) => ({
            ..._pick(member, ['id', 'name']),
            role: 'Member',
          })),
        ]
      }
    },
    async nextStep() {
      await this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'CommunityInviteRoleDialog',
        size: 'big',
        data: { payload: this.getPayload() },
      })
    },
    setSearch(search) {
      this.searchTerm = search.query
    },
    setEmailValidation(isValid) {
      this.areAllEmailsValid = isValid
    },
  }
}
</script>
<style lang="scss" scoped>
.invitation {
  &__heading {
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    color: $color-tertiary;
  }
  &__description {
    font-size: 16px;
    line-height: 19px;
    color: $color-text;
  }
}
</style>
