<template>
  <v-menu v-if="!isMobile" offset-y>
    <template v-slot:activator="{ on, attrs }">
      <v-btn
        fab
        outlined
        small
        :color="'secondary'"
        elevation="0"
        v-bind="attrs"
        v-on="on"
      >
        <v-icon> mdi-dots-horizontal </v-icon>
      </v-btn>
    </template>
    <v-list>
      <v-list-item>
        <v-btn plain>
          <v-list-item-title>
            {{ $i18n.t("mylives.invitations.resend_all_invitation") }}
          </v-list-item-title>
        </v-btn>
      </v-list-item>
      <v-list-item>
        <v-btn plain>
          <v-list-item-title>
            {{ $i18n.t("mylives.invitations.cancel_all_invitation") }}
          </v-list-item-title>
        </v-btn>
      </v-list-item>
    </v-list>
  </v-menu>
</template>
<script>
import breakpointsMixin from "@/mixins/breakpointsMixin";

export default {
  mixins: [
    breakpointsMixin
  ],
}
</script>
