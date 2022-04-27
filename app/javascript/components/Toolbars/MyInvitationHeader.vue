<template>
  <v-row>
    <v-col class="d-flex flex-row align-center">
      <v-spacer />
    </v-col>
    <v-col>
      <MyLifeMenu />
    </v-col>
    <v-col class="d-flex flex-row align-center">
      <v-spacer />
      <SelectViewType :viewType="viewType" @setViewType="setViewType" />
    </v-col>
  </v-row>
</template>

<script>
import MyLifeMenu from "./MyLife/MyLifeMenu";
import SelectViewType from "../Elements/SelectViewType";
import { mapActions, mapState } from "vuex";
export default {
  components: {
    MyLifeMenu,
    SelectViewType,
  },
  computed: {
    ...mapState({
      viewType: (state) => state.invitations.viewType,
    }),
  },
  methods: {
    ...mapActions({
      setViewType: "invitations/setViewType",
    }),
  },
};
</script>
