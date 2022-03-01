<template>
  <div
    v-on-clickaway="away"
    class="dropdown"
    :class="[{ 'open': isDropdownActive }, dropdownClass]"
  >
    <div
      @click="isDropdownActive=!isDropdownActive"
    >
      <a
        class="dropdown-toggle"
        aria-haspopup="true"
        aria-controls="{ 'dropdown-content' }"
      >
        <slot name="toggle" />
      </a>
    </div>

    <slot />
  </div>
</template>

<script>
import { mixin as clickaway } from 'vue-clickaway'

export default {
  mixins: [ clickaway ],
  props: {
    dropdownClass: {
      type: String,
      default: ''
    }
  },
  data () {
    return {
      isDropdownActive: false
    }
  },
  watch: {
    '$route': 'away'
  },
  methods: {
    away () {
      this.isDropdownActive = false
    }
  }
}
</script>

<style scoped>
</style>
