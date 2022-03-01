<template>
  <div>
    <v-btn
        rounded
        :outlined="viewType !== 'list'"
        color="primary"
        elevation="0"
        class="mx-1"
        @click="toggleViewType()"
    >
      <v-icon size="18" class="mr-1">mdi-reorder-horizontal</v-icon>
      <span class="button-text">List</span>
    </v-btn>
    <v-btn
        rounded
        :outlined="viewType === 'list'"
        color="primary"
        elevation="0"
        class="mx-1"
        @click="toggleViewType()"
    >
      <v-icon size="18" class="mr-1">mdi-view-grid-outline</v-icon>
      <span class="button-text">Covers</span>
    </v-btn>
  </div>
</template>

<script>

export default {
  props: {
    viewType: {
      type: String,
      default: 'grid'
    }
  },
  methods: {
    toggleViewType() {
      const type = this.viewType === 'list' ? 'grid' : 'list'
      this.$emit('setViewType', type)
    }
  }
}
</script>
<style lang="scss" scoped>
.button-text {
  font-weight: bold;
  font-size: 13px;
  line-height: 26px;
}
</style>
