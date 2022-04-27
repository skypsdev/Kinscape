<template>
  <v-app>
    <Header @toggleMainMenu="toggleMainMenu">
      <router-view name="toolbar"/>
    </Header>
    <v-main>
      <router-view v-if="!isLoading" :key="$route.path"/>
    </v-main>
    <Footer />
    <v-navigation-drawer
      v-model="showMainMenu"
      app
      right
      temporary
    >
      <MobileNavigation />
    </v-navigation-drawer>
    <Dialog />
    <Snackbar />
  </v-app>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import { camelizeKeys } from 'humps'

import MobileNavigation from '../components/Layout/MobileNavigation'
import Header from '../components/Layout/Header'
import Footer from '../components/Layout/Footer'
import Dialog from '../components/Layout/Dialog/Dialog'
import Snackbar from '../components/Layout/Snackbar'
import { on } from '@/utils/functions'

on(window, 'beforeunload', () => {
  ['tour','fromPreviousTourStep','fromMyLifeTourStep','tour-stories','tour-community'].forEach(key=>{
    localStorage.removeItem(key)
    })
})
export default {
  components: {MobileNavigation, Header, Footer, Dialog, Snackbar},
  props: {
    currentUser: {
      type: Object,
      required: true
    }
  },
  data: () => ({
    showMainMenu: false
  }),
  computed: {
    ...mapState({
      isLoading: state => state.core.isLoading
    }),
  },
  async mounted () {
    await this.initApp(this.currentUser)

    this.loadFamilies( null, { root: true })

    const { data } = camelizeKeys(this.currentUser)
    if (data.attributes.onboarding.pending) {
      this.showTooltips(false)

      switch (data.attributes.registrationMethod) {
      case 'member':
        this.$router.push({ 'name': 'communities' })
        break;
      case 'follower':
        this.$router.push({ 'name': 'stories' })
        break;
      default:
        this.$router.push({ 'name': 'myProfile' })
        break;
      }

      this.setDialog({
        component: 'WelcomeDialog',
        isToolbarHidden: true,
        size: 'big',
        persistent: true
      })
    }
  },
  methods: {
    ...mapActions({
      initApp: 'core/initApp',
      setDialog: 'layout/setDialog',
      showTooltips: 'core/showTooltips',
      loadFamilies: 'families/loadQuickList'
    }),
    toggleMainMenu() {
      this.showMainMenu = !this.showMainMenu
    }
  }
}
</script>

<style lang="scss">
  @import "app/javascript/assets/styles/index";

  .v-text-field--outlined .v-label--active {
    transform: translateY(-16px) translateX(-4px) scale(0.75);
  }
</style>
