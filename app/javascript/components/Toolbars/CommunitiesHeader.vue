<template>
  <v-row>
    <v-col>
    </v-col>
    <v-col class="d-flex flex-row align-center justify-center fill-height">
      <Search
        :searchTerm="searchTerm"
        @setSearch="setSearch"
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
import SelectViewType from '../Elements/SelectViewType'
import Search from '../Elements/Forms/Search'
import {mapActions, mapState} from 'vuex'

export default {
  components: {
    Search,
    SelectViewType,
  },
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
