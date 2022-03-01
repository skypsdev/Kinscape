<template>
  <DialogContent>
    <template v-slot:content>
      <v-col class="py-0 mt-11">
        <h2 class="invitation__heading">
          {{ $i18n.t('communities.inviteDialog.emailInvitationHeading') }}
        </h2>
        <p class="invitation__description mt-1">
          {{ $i18n.t('communities.inviteDialog.emailInvitationDescription',{
          communityName: community.name }) }}
        </p>
      </v-col>
      <v-col class="py-0 mb-6">
        <EmailPicker class="mt-7" v-model="emails" @validate="setEmailValidation"/>
      </v-col>
      <v-divider class="mx-3"/>
      <v-col class="py-0">
        <h2 class="invitation__heading mt-6">
          {{ $i18n.t('communities.inviteDialog.memberInvitationHeading') }}
        </h2>
        <p class="invitation__description mt-1">
          {{ $i18n.t('communities.inviteDialog.memberInvitationDescription') }}
        </p>
      </v-col>
      <v-col cols="12" md="4">
        <Search :search-term="searchTerm" @setSearch="setSearch"/>
      </v-col>
      <v-col>
        <ToggleSelect v-model="selectedMembers" :items="members"/>
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
          {{ $i18n.t('communities.inviteDialog.cancel') }}
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
          {{ $i18n.t('communities.inviteDialog.next') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'
import Search from "../Elements/Forms/Search";
import ToggleSelect from "../Elements/Forms/ToggleSelect";
import EmailPicker from "../Elements/Forms/EmailPicker";

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
      simpleList: state => state.families.simpleList,
      dialog: state => state.layout.dialog
    }),
    members() {
      const search = this.searchTerm.toLowerCase()
      const allKinships = this.simpleList.members.map(item => {
        return {
          id: item.attributes.userId,
          image: item.attributes.avatarUrl,
          name: item.attributes.nickname,
        }
      })
      const kinshipsGroupedByUserId = allKinships.reduce(function(array, object) {
        (array[object['id']] = array[object['id']] || []).push(object)
        return array
      }, {})

      const filteredKinships = Object.keys(kinshipsGroupedByUserId).map(id => {
        const userKinships = kinshipsGroupedByUserId[id]
        return userKinships.find(member => member.image !== null) || userKinships[0]
      })
      return filteredKinships.filter(item => {
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
    isFormValid () {
      return this.hasSelectedMembers || (this.hasEmails && this.areAllEmailsValid)
    }
  },
  watch: {
    selectedMembers () {
      this.search = ''
    },
  },
  created() {
    if (this.dialog.data?.payload) {
      this.emails = this.dialog.data.payload.users
          .filter((val) => val.email)
          .map(item => {
            return item.email
          })
      this.selectedMembers = this.dialog.data.payload.users
          .filter((val) => val.name)
          .map(item => {
            return { id: item.id, name: item.name }
          })
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
    async nextStep () {
      let payload = {
        users: [
            ...this.emails.map((email) => {
              return {
                email: email,
                role: 'Member',
              }
            }),
            ...this.selectedMembers.map((member) => {
              return {
                id: member.id,
                role: 'Member',
                name: member.name,
              }
            }),
        ]
      }
      await this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'CommunityInviteRoleDialog',
        size: 'big',
        data: { payload },
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
