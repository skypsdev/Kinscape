<template>
  <v-row>
    <v-col class="d-flex flex-row align-center">
      <FilterByCommunity/>
    </v-col>
    <v-col class="d-flex flex-row align-center justify-center fill-height">
      <Search
        :searchTerm="$route.query.query"
        @setSearch="handleFilter"
        class="stories__search"
      />
    </v-col>
    <v-col class="d-flex flex-row align-center justify-end fill-height">
      <SelectViewType
        :viewType="viewType"
        @setViewType="setViewType"
      />
    </v-col>
  </v-row>
</template>

<script>
import FilterByCommunity from './Stories/FilterByCommunity'
import SelectViewType from '../Elements/SelectViewType'
import Search from '../Elements/Forms/Search'
import {mapActions, mapState} from 'vuex'

export default {
  components: {
    FilterByCommunity,
    Search,
    SelectViewType
  },
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
      }).catch(()=>{})
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
