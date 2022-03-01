<template>
  <v-hover v-if="filters.authorId || filters.categories.length" v-slot="{ hover }">
    <v-btn
      class="clear-filters-button"
      color="primary"
      text
      @click="clearFilters"
    >
      <v-icon class="mr-1">{{hover ? 'mdi-close-circle' : 'mdi-close-circle-outline'}}</v-icon>
      {{$i18n.t('stories.filters.clear_all_filters')}}
    </v-btn>
  </v-hover>
</template>

<script>
import {mapActions, mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      filters: state => state.stories.filters
    })
  },
  methods: {
    ...mapActions({
      setStoryFilters: 'stories/setStoryFilters',
      clearStoryFilters: 'stories/clearStoryFilters'
    }),
    clearFilters() {
      const filters = {...this.filters}
      filters.authorId = null
      filters.categories = []
      this.setStoryFilters(filters)
      this.$router.replace({ query: {
          ...this.$route.query,
          ...filters,
        } }).catch(()=>{})
    }
  }
}
</script>

<style lang="scss" scoped>
.clear-filters-button {
  font-weight: bold;
  font-size: 18px;
  line-height: 24px;
  &::before {
    display: none !important;
  }
}
</style>
