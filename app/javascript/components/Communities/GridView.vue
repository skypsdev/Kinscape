<template>
  <v-row
    infinite-wrapper
    class="community-wrapper"
  >
    <v-col
      v-for="community in communities"
      :key="community.id"
      :data-community-id="community.id"
      class="d-flex justify-center col-6 col-sm-4 col-md-3"
      :style="
        $vuetify.breakpoint.xlOnly
          ? ' flex: 1 0 18%; max-width: 18%; margin: 0 1%'
          : ''
      "
    >
      <CommunityCard :community="community" />
    </v-col>
  </v-row>
</template>
<script>
import CommunityCard from "./CommunityCard";
import { mapState } from "vuex";

export default {
  components: { CommunityCard },
  computed: {
    ...mapState({
      communities: store => store.families.all
    }),
  }
}
</script>
