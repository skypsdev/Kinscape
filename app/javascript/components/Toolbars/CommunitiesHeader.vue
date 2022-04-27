<template>
  <div class="flex-grow-1 d-flex flex-nowrap">
    <v-spacer />
    <Search
      :searchTerm="searchTerm"
      @setSearch="setSearch"
    />
    <v-spacer v-if="!isMobile" />
    <SelectViewType
      :viewType="viewType"
      @setViewType="setViewType"
    />
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import Search from '../Elements/Forms/Search'
import SelectViewType from '../Elements/SelectViewType'
import breakpointsMixin from '@/mixins/breakpointsMixin'

export default {
  components: {
    Search,
    SelectViewType,
  },
  mixins: [breakpointsMixin],
  computed: {
    ...mapState({
      viewType: state => state.families.viewType,
      searchTerm: state => state.families.filters.search.query
    })
  },
  methods: {
    ...mapActions({
      setViewType: 'families/setCommunitiesViewType',
      setSearch: 'families/setCommunitiesSearch'
    })
  }
}
</script>
