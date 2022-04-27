<template>
  <div class="flex-grow-1 d-flex flex-nowrap">
    <FilterByCommunity/>
    <v-spacer v-if="!isMobile" />
    <Search
      :searchTerm="$route.query.query"
      @setSearch="handleFilter"
      class="stories__search"
    />
    <v-spacer />
    <SelectViewType
      :viewType="viewType"
      @setViewType="setViewType"
    />
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import FilterByCommunity from './Stories/FilterByCommunity'
import SelectViewType from '../Elements/SelectViewType'
import Search from '../Elements/Forms/Search'
import breakpointsMixin from '@/mixins/breakpointsMixin'

export default {
  components: {
    FilterByCommunity,
    Search,
    SelectViewType
  },
  mixins: [breakpointsMixin],
  computed: {
    ...mapState({
      viewType: state => state.stories.viewType
    })
  },
  methods: {
    ...mapActions({
      setViewType: 'stories/setStoriesViewType',
      setStoryFilters: 'stories/setStoryFilters'
    }),
    handleFilter(filter) {
      this.$router.replace({
        query: {
          ...this.$route.query,
          ...filter
        }
      })
      this.setStoryFilters(filter)
    }
  }
}
</script>

<style lang="scss" scoped>
.stories__search {
  max-width: 200px;
}
</style>
