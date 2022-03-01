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
        :src="require('../../assets/images/logo-large.svg')"
        width="173"
        height="35"
      />
      <v-img
        class="hidden-sm-and-up mr-3"
        :src="require('../../assets/images/logo-small.svg')"
        width="31"
        height="31"
      />
    </router-link>
    <MainNavigation
      v-if="!isMobile"
      class="hidden-sm-and-down"
    />
    <v-spacer/>
    <div class="d-flex align-center">
      <v-progress-circular
        v-if="loading"
        indeterminate
        color="red"
        class="mr-1"
      />
    </div>
    <!-- We don't want these buttons on the showcase version of the site -->
    <template v-if="!this.$isShowcase">
      <ActionButton/>
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
    <template v-else>
    <v-btn
        text
        href="https://kinscape.com/"
        class="app-bar-button app-bar-button--new-story"
        :title="$i18n.t('showcase.leave_showcase')"
    >
      <v-icon>mdi-arrow-left-circle-outline</v-icon>
      <div>{{ $i18n.t('showcase.leave_showcase') }}</div>
    </v-btn>
    </template>
    <v-menu
      bottom
      offset-y
    >
      <template v-slot:activator="{ on, attrs }">
        <v-btn
          class="hidden-sm-and-down"
          icon
          v-bind="attrs"
          v-on="on"
        >
          <v-icon>mdi-menu</v-icon>
        </v-btn>
      </template>
      <v-list dense>
        <v-list-item href="/account">
          <v-list-item-content>
            <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.account') }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>

        <v-list-item link target="_blank" href="https://intercom.help/kinscape">
          <v-list-item-content>
            <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.help_center') }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>

        <v-list-item href="/sign_out">
          <v-list-item-content>
            <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.sign_out') }}</v-list-item-title>
          </v-list-item-content>
        </v-list-item>
      </v-list>
    </v-menu>
    <template
      v-if="isSubHeaderShown"
      v-slot:extension
    >
      <slot/>
    </template>
  </v-app-bar>
</template>

<script>
import {mapActions, mapGetters, mapState} from 'vuex'
import MainNavigation from './MainNavigation'
import breakpointsMixin from '../../mixins/breakpointsMixin'
import ActionButton from "./Header/ActionButton";

export default {
  components: {
    ActionButton,
    MainNavigation
  },
  mixins: [
    breakpointsMixin
  ],
  data: () => ({
    isPageScrolled: false,
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
  created() {
    window.addEventListener('scroll', this.handleScroll);
  },
  destroyed() {
    window.removeEventListener('scroll', this.handleScroll);
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
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
