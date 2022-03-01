<template>
  <v-container class="communities__grid my-12">
    <ListView v-if="isList"/>
    <GridView v-else/>
    <EmptyState v-if="!isLoading && !communities.length"/>
    <FamiliesLoader v-if="isLoading && !isList" class="legacy-styles"/>
    <infinite-loading
      v-if="hasMorePages"
      spinner="spiral"
      force-use-infinite-wrapper
      @infinite="loadMore"
    >
      <div slot="no-more" />
    </infinite-loading>
  </v-container>
</template>
<script>
import {mapActions, mapGetters, mapState} from 'vuex'
import FamiliesLoader from '../../components/families/families-loader'
import GridView from "../../components/Communities/GridView";
import ListView from "../../components/Communities/ListView";
import EmptyState from "../../components/Communities/EmptyState";

export default {
  name: 'Communities',
  components: {EmptyState, ListView, GridView, FamiliesLoader },
  computed: {
    ...mapState({
      viewType: state => state.families.viewType,
      searchTerm: state => state.families.filters.search.query,
      currentUser: state => state.core.user
    }),
    ...mapGetters({
      isLoading: 'families/isLoading',
      isError: 'families/isError',
      currentPage: 'families/currentPage',
      totalPages: 'families/totalPages',
      communities: 'families/all'
    }),
    hasMorePages () {
      return this.currentPage && this.currentPage < this.totalPages
    },
    isList() {
      return this.viewType !== 'grid'
    }
  },
  watch: {
    searchTerm () {
      this.loadFamiliesWithFilters()
    }
  },
  created () {
    this.loadFamiliesWithFilters()
  },
  mounted () {
    let query = Object.assign({}, this.$route.query)
    let failMessage
    let successMessage
    if (Object.keys(query).length !== 0) {
      if (query.accepted === 'true') {
        failMessage = 'Action perform only once'
        delete query.accepted
      } else if (query.accepted === 'false') {
        successMessage = this.$i18n.t('families.flash.alert.decline')
        delete query.accepted
      } else if (query.expire === 'true') {
        failMessage = 'This link is expire.'
        delete query.expire
      } else if (query.expire === 'false') {
        failMessage = 'This link is not active.'
        delete query.expire
      } else if (query.error === 'owner') {
        failMessage = this.$i18n.t('invitations.flash.error.owner')
        delete query.error
      } else if (query.error === 'unauthorized') {
        failMessage = this.$i18n.t('invitations.flash.error.unauthorized')
        delete query.error
      }

      this.$router.replace({ query })
      if (failMessage) {
        this.setSnackbar({
          color: 'error',
          messages: [failMessage]
        })
      } else if (successMessage) {
        this.setSnackbar({
          color: 'success',
          messages: [successMessage]
        })
      }
    }
  },
  methods: {
    ...mapActions({
      loadFamilies: 'families/loadNext',
      clearFamilies: 'families/clearFamilies',
      setSnackbar: 'layout/setSnackbar'
    }),
    async loadMore ($state) {
      try {
        await this.loadFamilies({query: this.searchTerm})
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    },
    loadFamiliesWithFilters () {
      this.clearFamilies()
      let params = { query: this.searchTerm, page: 1 }
      this.loadFamilies(params)
    },
    familyChanged (familyID) {
      window.location = '/communities/' + familyID + '/edit'
    }
  }
}
</script>
<style scoped lang="scss">
.communities {
  &__grid {
    padding: 0 12px;
    margin: 0 auto;
    width: 100%;
    max-width: 1416px;
    @media #{map-get($display-breakpoints, 'lg-and-down')} {
      max-width: 1116px;
    }
  }
}
</style>
