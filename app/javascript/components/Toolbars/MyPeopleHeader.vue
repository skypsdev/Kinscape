<template>
  <div class="flex-grow-1 d-flex align-center space-between">
    <BackButton v-if="isMobile" />
    <MyLifeMyPeopleBreadcrumbs
      v-else-if="$route.name == 'myPeoplePersonProfile'"
    />
    <v-spacer />
    <MyLifeMenu :has-simulated-path="hasSimulatedPath" />
    <v-spacer />
    <portal-target name="my-people-header"> </portal-target>
  </div>
</template>

<script>
import MyLifeMenu from '@/components/Toolbars/MyLife/MyLifeMenu.vue'
import MyLifeMyPeopleBreadcrumbs from '@/components/Toolbars/MyLife/MyLifeMyPeopleBreadcrumbs.vue'

import breakpointsMixin from "@/mixins/breakpointsMixin"
export default {
  components: {
    MyLifeMenu,
    MyLifeMyPeopleBreadcrumbs
  },
  mixins: [breakpointsMixin],
  props: {
    hasSimulatedPath: {
      type: Boolean,
      default: false
    }
  },
}
</script>
<style lang="scss" >
.breadcrumbs__item--last {
  color: $secondary !important;
}
</style>