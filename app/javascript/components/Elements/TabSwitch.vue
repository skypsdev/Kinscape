<template>
  <div class="d-flex flex-row align-center justify-center fill-height">
    <v-btn
        v-for="button in buttons"
        :key="button.label"
        rounded
        :outlined="!isCurrentPath(button.to.name)"
        color="primary"
        elevation="0"
        class="tab-switch__button mx-2"
        :to="button.to"
        :title="$i18n.t(button.title)"
    >
      {{ $i18n.t(button.label) }}
    </v-btn>
  </div>
</template>

<script>
export default {
  props: {
    buttons: {
      type: Array,
      required: true
    },
    simulatePath: {
      type: String,
      default: ''
    }
  },
  methods: {
    isCurrentPath(name) {
      return this.simulatePath ? this.simulatePath === name : this.$route.name === name
    }
  }
}
</script>
<style lang="scss" scoped>
.tab-switch {
  &__button {
    min-width: 100px !important;
  }
}
</style>
