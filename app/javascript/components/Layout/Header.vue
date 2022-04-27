<template>
  <v-app-bar
    ref="appBar"
    app
    height="60"
    extension-height="56"
    color="disabled"
    :flat="!isPageScrolled"
  >
    <router-link to="/stories">
      <v-img
        class="hidden-xs-only mr-3"
        contain
        :src="require('../../assets/images/logo-large.svg')"
        width="173"
        height="35"
      />
      <v-img
        class="hidden-sm-and-up mr-3"
        contain
        :src="require('../../assets/images/logo-small.svg')"
        width="31"
        height="31"
      />
    </router-link>
    <MainNavigation
      v-if="!isMobile"
      class="hidden-sm-and-down"
    />
    <v-spacer />
    <div class="d-flex align-center">
      <v-progress-circular
        v-if="loading"
        indeterminate
        color="red"
        class="mr-1"
      />
    </div>
    <template>
      <ActionButton />
      <v-btn
        text
        class="app-bar-button"
        :title="$i18n.t('header.message_title')"
        @click="openConversationDialog"
      >
        <v-icon>mdi-email-outline</v-icon>
        <div>Message</div>
      </v-btn>
      <v-app-bar-nav-icon
        class="hidden-md-and-up"
        @click.stop="$emit('toggleMainMenu')"
      />
    </template>
    <BurgerButton />
    <template
      v-if="isSubHeaderShown"
      v-slot:extension
    >
      <slot />
    </template>
  </v-app-bar>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'
import MainNavigation from './MainNavigation'
import breakpointsMixin from '../../mixins/breakpointsMixin'
import ActionButton from "./Header/ActionButton";
import BurgerButton from "./Header/BurgerButton";

export default {
  components: {
    ActionButton,
    BurgerButton,
    MainNavigation
  },
  mixins: [
    breakpointsMixin
  ],
  data: () => ({
    isPageScrolled: false
  }),
  computed: {
    ...mapGetters({
      //TODO: REFACTORING - one getter for global loading`
      isLoading: 'isLoading',
      sectionUpdateQueued: 'sectionUpdateQueued',
      getForLoad: 'vaults/getForLoad'
    }),
    ...mapState({
      communities: state => state.families.all,
      searchTerm: state => state.families.filters.search.query
    }),
    loading() {
      return this.isLoading || this.sectionUpdateQueued || this.getForLoad
    },
    isSubHeaderShown() {
      return this.searchTerm || this.isShowingCommunitiesEmptyState || this.hasHideToolbarAndIsNotCommunities
    },
    isCommunities() {
      return this.$route.name === 'communities'
    },
    hasHideToolbarAndIsNotCommunities() {
      return !this.$route.meta.hideToolbar && !this.isCommunities
    },
    isShowingCommunitiesEmptyState() {
      return this.isCommunities && this.communities.length;
    },
  },
  mounted() {
    window.addEventListener('scroll', this.handleScroll);
  },
  destroyed() {
    window.removeEventListener('scroll', this.handleScroll);
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    showTour() {
      localStorage.setItem('tour', true)
      if (this.$route.name != 'communities') {
        this.$router.push('/communities')
      } else {
        this.$eventBus.emit('show-tour')
      }
    },
    openConversationDialog() {
      this.setDialog({
        component: 'SendMessageToMembersDialog',
        title: this.$i18n.t('requests.title')
      })
    },
    handleScroll() {
      this.isPageScrolled = window.scrollY > 0
    },
  }
}
</script>
