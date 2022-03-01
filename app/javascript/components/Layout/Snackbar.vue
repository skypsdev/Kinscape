<template>
  <v-snackbar
    v-model="show"
    :color="snackbar.color"
    timeout="5000"
  >
    <div
      v-for="(message, index) in snackbar.messages"
      :key="index"
      class="subtitle-2"
    >
      {{ message }}
    </div>
  </v-snackbar>
</template>

<script>
import { mapState, mapActions } from 'vuex';

export default {
  computed: {
    ...mapState({
      snackbar: state => state.layout.snackbar
    }),
    show: {
      get() {
        return this.snackbar.active;
      },
      set() {
        setTimeout(this.closeSnackbar, 500);
      },
    },
  },
  
  methods: {
    ...mapActions({
      closeSnackbar: 'layout/closeSnackbar'
    })
  },
};
</script>
