<template>
  <v-tabs
    icons-and-text
    :centered="isMobile"
    :hide-slider="isMobile"
    :height="isMobile ? 54 : 60"
    class="main-navigation-tabs"
  >
    <v-tabs-slider></v-tabs-slider>
    <v-tab 
      id="intro-communities-list-of-communities"
      :title="$i18n.t('header.families_title')"
      to="/communities"
    >
      {{ $i18n.t('header.families') }}
      <v-icon>mdi-account-multiple-outline</v-icon>
    </v-tab>

    <v-tab
      id="intro-stories-list-of-stories"
      :title="$i18n.t('header.stories_title')"
      to="/stories"
    >
      {{ $i18n.t('header.stories') }}
      <v-icon>mdi-text-box-outline</v-icon>
    </v-tab>

    <v-tab
       id="intro-my-life-list-of-my-life"
      :title="$i18n.t('header.mylife_title')"
      to="/mylife"
    >
      {{ $i18n.t('header.mylife') }}
      <v-icon>mdi-account</v-icon>
    </v-tab>
  </v-tabs>
  
</template>

<script>
import breakpointsMixin from '../../mixins/breakpointsMixin'

export default {
  mixins: [breakpointsMixin]
}
</script>
