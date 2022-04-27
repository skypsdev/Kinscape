<template>
  <v-row>
    <v-col
      v-for="invitation in sentInvitations"
      :key="invitation.id"
      :style="$vuetify.breakpoint.lgAndUp ? ' flex: 1 0 18%;' : ''"
      cols="6"
      md="3"
      sm="4"
    >
      <div class="d-flex justify-center">
        <v-avatar min-height="168" min-width="168" color="#E7E7E7">
          <v-icon class="icon_large"> mdi-account-outline </v-icon>
        </v-avatar>
        <InvitationMenu />
      </div>
      <div class="text-center pt-2">
        <strong> {{ invitation.attributes.email }} </strong>
      </div>
    </v-col>
  </v-row>
</template>
<script>
import InvitationMenu from "./InvitationMenu"
import breakpointsMixin from "../../mixins/breakpointsMixin"
export default {

  components: {
    InvitationMenu
  },
  mixins: [
    breakpointsMixin
  ],
  props: {
    sentInvitations: {
      type: Array,
      required: true
    },
    resendInvitation: {
      type: Function,
      required: true
    },
    cancelInvitation: {
      type: Function,
      required: true
    }
  }
};
</script>
<style scoped>
.icon_large {
  font-size: 100px;
}
</style>
