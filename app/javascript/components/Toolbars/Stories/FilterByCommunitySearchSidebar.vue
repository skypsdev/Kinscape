<template>
  <v-col class="story-switcher__sidebar--right ml-md-5">
    <v-list dense class="story-switcher__list transparent">
      <v-list-item class="story-switcher__sidebar-title">
        <v-icon
          class="mr-2 hidden-sm-and-down"
          color="primary"
          @click="toggleSidebar"
        >
          mdi-arrow-left
        </v-icon>
        <v-icon
          class="mr-2 hidden-md-and-up"
          color="primary"
          large
          @click="toggleSidebar"
        >
          mdi-chevron-left
        </v-icon>
        {{ title }}
      </v-list-item>

      <v-list-item class="story-switcher__search mb-4 mt-2">
        <Search :searchTerm="search" @setSearch="searchRecords" />
      </v-list-item>

      <v-list-item
        v-for="sidebarItem in filteredRecords"
        :key="sidebarItem.id"
        class="story-switcher__link"
        :class="{
          'story-switcher__link--active':
            sidebarItem.id === selectedItemId,
        }"
        @click="selectFilter(sidebarItem.filters)"
      >
        <v-icon v-if="sidebarItem.icon" class="story-switcher__icon">
          {{ sidebarItem.icon }}
        </v-icon>
        <Avatar v-else :src="sidebarItem.avatar" size="small" />
        <span class="pl-3" v-text="sidebarItem.name" />
      </v-list-item>
    </v-list>
  </v-col>
</template>

<script>
import Avatar from '@/components/Elements/Avatar'
import Search from '@/components/Elements/Forms/Search'

export default {
  name: "FilterByCommunitySearchSidebar",
  components: {
    Avatar,
    Search
  },
  props: {
    toggleSidebar: {
      type: Function,
      default: () => null,
      required: true
    },
    selectFilter: {
      type: Function,
      default: () => null,
      required: true
    },
    title: {
      type: String,
      default: "",
      required: true
    },
    items: {
      type: Array,
      default: () => [],
      required: true
    },
    selectedItemId: {
      type: [String, Number],
      default: ''
    }
  },
  data() {
    return {
      search: ''
    }
  },
  computed: {
    filteredRecords() {
      if (this.search == '') return this.items

      let { search } = this
      search = search.trim().toLowerCase()

      return this.items.filter(({ name }) => name.toLowerCase().includes(search))
    }
  },
  methods: {
    searchRecords({ query }) {
      this.search = query
    }
  }
};
</script>

<style></style>
