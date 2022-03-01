<template>
  <v-container class="members__grid my-12">
    <v-row>
      <v-col class="d-flex flex-row align-center">
        <h1 v-if="reqType === 'defaults'" class="f--tertiary">
          {{
            $i18n.t('communities.members.heading', { community: family.name })
          }}
        </h1>
        <h1 v-else class="f--tertiary">
          {{
            $i18n.t('communities.invitations.heading', {
              community: family.name
            })
          }}
        </h1>
        <h4 class="f--grey ml-5">
          {{ $i18n.t('communities.members.total', { count: members.length }) }}
        </h4>
      </v-col>
    </v-row>
    <v-row class="mt-3 flex-column flex-md-row">
      <v-col class="col-lg-3">
        <Search
          class="members__search"
          :search-term="search"
          @setSearch="filterResults"
        />
      </v-col>
      <v-col class="col-lg-3 d-flex">
        <v-btn
            v-if="isCurrentUserAdmin"
            class="mr-4"
            rounded
            outlined
            color="primary"
            elevation="0"
            @click="showInviteModal"
        >
          <v-icon class="pr-2">mdi-plus-circle-outline</v-icon>
          <span>
            {{ $i18n.t('communities.members.invite') }}
          </span>
        </v-btn>
        <v-btn
            v-if="isCurrentUserAdmin"
            class="ml-2"
            rounded
            outlined
            color="primary"
            elevation="0"
            @click="showAddOfflineMemberDialog"
        >
          <v-icon class="pr-2">mdi-account-plus-outline</v-icon>
          <span>
            {{ $i18n.t('communities.members.add_offline') }}
          </span>
        </v-btn>
      </v-col>
    </v-row>
    <ListView v-if="isList" :is-invitation="isInvitation" :req-type="reqType" :final-member-list="finalMemberList"/>
    <GridView
        v-else
        :is-invitation="isInvitation"
        :req-type="reqType"
        :final-member-list="finalMemberList"
    />
    <FamiliesLoader v-if="isLoading" />
    <infinite-loading
        v-if="hasMorePages"
        spinner="spiral"
        @infinite="loadMore"
    >
      <div slot="no-more" />
    </infinite-loading>
  </v-container>
</template>
<script>
import { mapGetters, mapActions, mapState } from 'vuex'
import FamiliesLoader from '../../components/families/families-loader'
import Search from "../../components/Elements/Forms/Search";
import ListView from "../../components/Community/Members/ListView";
import GridView from "../../components/Community/Members/GridView";

export default {
  name: 'Members',
  components: {
    GridView,
    ListView,
    Search,
    FamiliesLoader,
  },
  props: {
    reqType: {
      type: String,
      required: true
    }
  },
  data: () => ({
    finalMemberList: [],
    search: ''
  }),
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      members: state => state.members.members,
      family: state => state.families.community,
      viewType: state => state.members.viewType,
    }),
    ...mapGetters({
      isLoading: 'members/isLoading',
      currentPage: 'members/currentPage',
      totalPages: 'members/totalPages',
      flashMessage: 'flashMessage',
    }),
    communityId () {
      return this.$route.params.id
    },
    hasMorePages () {
      return this.currentPage && this.currentPage < this.totalPages
    },
    queryParams () {
      return {
        ...this.filters
      }
    },
    isCurrentUserAdmin() {
      return this.family.isAdmin
    },
    isInvitation () {
      return this.reqType !== 'defaults'
    },
    isList() {
      return this.viewType !== 'grid'
    }
  },
  watch: {
    queryParams () {
      this.loadMembersWithFilters()
    },
    reqType () {
      this.loadMembersWithFilters()
    },
    members () {
      if (this.members.length !== this.finalMemberList.length) {
        this.search = ''
        this.finalMemberList = this.members
      }
    }
  },
  created () {
    this.loadMembersWithFilters()
  },
  async mounted () {
    await this.getCommunity({
      id: this.communityId
    })
  },
  methods: {
    ...mapActions({
      getCommunity: 'families/getCommunity',
      loadMembers: 'members/loadNext',
      clearMembers: 'members/clearMembers',
      setDialog: 'layout/setDialog'
    }),
    showInviteModal () {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.family.type }),
        size: 'big',
        component: 'CommunityInviteDialog',
      })
    },
    showAddOfflineMemberDialog () {
      this.setDialog({
        title: this.$i18n.t('communities.members.add_offline'),
        size: 'big',
        component: 'AddOfflineMemberDialog',
      })
    },
    async loadMore ($state) {
      try {
        let payload = {
          'id': this.communityId,
          'type': this.reqType
        }
        await this.loadMembers(payload, this.queryParams)
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    },
    async loadMembersWithFilters () {
      this.clearMembers()
      let params = { ...this.queryParams, page: 1 }
      let payload = {
        'id': this.communityId,
        'type': this.reqType
      }
      await this.loadMembers(payload, params)
      this.finalMemberList = this.members
    },
    filterResults(search) {
      this.finalMemberList = this.members.filter((member) => {
        const query = search.query.toLowerCase()
        return member.name.toLowerCase().includes(query)
            || member.nickname.toLowerCase().includes(query)
            || member.email.toLowerCase().includes(query)
      })
    }
  }
}
</script>
<style scoped lang="scss">
.members {
  &__grid {
    padding: 0 12px;
    margin: 0 auto;
    width: 100%;
    max-width: 1112px;
  }
  &__search {
    min-width: 260px;
  }
}
</style>
