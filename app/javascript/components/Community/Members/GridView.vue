<template>
  <v-row v-if="finalMemberList.length" infinite-wrapper>
    <v-col
        v-for="member in finalMemberList"
        :key="member.id"
        class="d-flex justify-center col-6 col-sm-4 col-md-3"
        :style="
      $vuetify.breakpoint.lgAndUp
        ? ' flex: 1 0 18%; max-width: 18%; margin: 0 1%'
        : ''
    "
    >
    <CommunityTile
        :member="member"
        :type="reqType"
        :is-invitation="isInvitation"
    />
    </v-col>
  </v-row>
</template>
<script>
import CommunityTile from "./CommunityTile";
import { mapState } from "vuex";

export default {
  components: { CommunityTile },
  props: {
    isInvitation: {
      type: Boolean,
      default: false
    },
    finalMemberList: {
      type: Array,
      default: () => []
    },
    reqType: {
      type: String,
      default: "defaults"
    }
  },
  computed: {
    ...mapState({
      members: store => store.families.all
    }),
  }
}
</script>
