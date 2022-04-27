<template>
  <div class="select-view-type">
    <v-btn
        class="d-none d-sm-inline-flex mx-1"
        rounded
        :outlined="viewType !== 'list'"
        color="primary"
        elevation="0"
        @click="toggleViewType()"
    >
      <v-icon size="18" class="mr-1">mdi-reorder-horizontal</v-icon>
      <span class="button-text">List</span>
    </v-btn>
    <v-btn
        class="d-none d-sm-inline-flex mx-1"
        rounded
        :outlined="viewType === 'list'"
        color="primary"
        elevation="0"
        @click="toggleViewType()"
    >
      <v-icon size="18">mdi-view-grid-outline</v-icon>
      <span class="button-text">Covers</span>
    </v-btn>
    <v-btn
        class="d-sm-none mx-1"
        rounded
        color="primary"
        elevation="0"
        fab
        small
        :outlined="viewType !== 'list'"
        @click="toggleViewType()"
    >
      <v-icon size="18">mdi-reorder-horizontal</v-icon>
    </v-btn>
    <v-btn
        class="d-sm-none mx-1"
        rounded
        color="primary"
        elevation="0"
        fab
        small
        :outlined="viewType === 'list'"
        @click="toggleViewType()"
    >
      <v-icon size="18" class="mr-1">mdi-view-grid-outline</v-icon>
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
      this.$vuetify.goTo(document.body, 0)
    }
  }
}
</script>
<style lang="scss" scoped>
.select-view-type {
  min-width: 108px;
}
.button-text {
  font-weight: bold;
  font-size: 13px;
  line-height: 26px;
}
</style>
