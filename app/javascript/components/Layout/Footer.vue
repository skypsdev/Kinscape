<template>
  <v-footer
    :height="isMobile ? 56 : 64"
    :color="isMobile ? 'dark_white' : 'white'"
    :fixed="isMobile"
    class="py-0"
  >
    <v-row
      v-if="!isMobile"
      class="pr-md-16"
    >
      <v-col>
        <v-btn
          plain
          target="_blank"
          href="/pages/terms_of_use"
        >
          Terms of Use
          <v-icon color="primary">mdi-chevron-right</v-icon>
        </v-btn>
        <v-btn
          plain
          target="_blank"
          href="/pages/privacy"
        >
          Privacy Policy
          <v-icon color="primary">mdi-chevron-right</v-icon>
        </v-btn>
        <v-btn
          plain
          target="_blank"
          href="https://intercom.help/kinscape"
        >
          Help Center
          <v-icon color="primary">mdi-chevron-right</v-icon>
        </v-btn>
      </v-col>
      <v-col class="d-flex justify-md-end">
        <div class="pt-1">
          ©ELife {{ new Date().getFullYear() }}. All Rights Reserved.
        </div>
      </v-col>
    </v-row>
    <MainNavigation v-if="isMobile" />
  </v-footer>
</template>

<script>
import MainNavigation from './MainNavigation'
import breakpointsMixin from '../../mixins/breakpointsMixin'

export default {
  components: {
    MainNavigation
  },
  mixins: [
    breakpointsMixin
  ]
}
</script>
