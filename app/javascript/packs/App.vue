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

import MobileNavigation from '../components/Layout/MobileNavigation'
import Header from '../components/Layout/Header'
import Footer from '../components/Layout/Footer'
import Dialog from '../components/Layout/Dialog/Dialog'
import Snackbar from '../components/Layout/Snackbar'

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
  watch: {
    currentUser: {
      immediate: true,
      deep: true,
      handler(user) {
        this.initApp(user)
      }
    }
  },
  methods: {
    ...mapActions({
      initApp: 'core/initApp'
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
