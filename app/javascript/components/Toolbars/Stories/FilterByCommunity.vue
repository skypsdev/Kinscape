<template>
  <div>
    <v-menu
      bottom
      offset-y
      nudge-left="100"
      v-model="displaySwitcher"
      content-class="story-switcher"
      :close-on-content-click="false"
    >
      <template v-slot:activator="{ attrs }">
        <div
          class="story-switcher__activator"
          @click="toggleSwitcher"
        >
          <v-btn
            rounded
            outlined
            color="primary"
            elevation="0"
            class="mx-1"
            v-bind="attrs"
          >
            <Avatar
              v-if="selectedItem.avatar"
              :src="selectedItem.avatar"
              class="mr-1"
              size="small"
            />
            <v-icon v-else class="mr-1">{{ selectedItem.icon }}</v-icon>
            {{ selectedItem.name }}
            <v-icon>{{displaySwitcher ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
          </v-btn>
        </div>
      </template>
      <div class="story-switcher__wrapper">
        <v-row no-gutters>
          <v-col
            class="story-switcher__sidebar--left"
            :class="{ 'hidden-sm-and-down' : sidebarIsActive}"
          >
            <v-list dense class="story-switcher__list pb-0">
              <div
                v-for="(group, index) in storySwitcherItems"
                :key="index"
                class="pb-4"
              >
                <v-list-item
                  v-if="group.title"
                  class="story-switcher__title"
                >
                  {{ group.title }}
                </v-list-item>
                <v-list-item
                  v-for="item in group.items.slice(0, 3)"
                  :key="item.id"
                  class="story-switcher__link"
                  :class="{'story-switcher__link--active': selectedItem.id === item.id}"
                  @click="selectFilter(item.filters)"
                >
                  <v-icon v-if="item.icon" class="story-switcher__icon">
                    {{ item.icon }}
                  </v-icon>
                  <Avatar
                    v-else
                    :src="item.avatar"
                    size="small"
                  />
                  <span class="pl-3">
                    {{ item.name }}
                  </span>
                </v-list-item>
                <v-list-item
                  v-if="group.more"
                  class="story-switcher__link--more pr-6"
                  @click="toggleSidebar(group)"
                >
                  <template v-if="selectedGroup(group)">
                    <v-icon color="primary">mdi-chevron-left</v-icon> <span class="mr-2">{{ $i18n.t('stories.show_less') }}</span>
                  </template>
                  <template v-else>
                    {{ $i18n.t('stories.show_all') }} <v-icon color="primary">mdi-chevron-right</v-icon>
                  </template>
                </v-list-item>
                <v-divider v-if="group.divider" class="mt-4 mx-2"/>
              </div>
            </v-list>
          </v-col>
          <v-col
            v-if="sidebarIsActive"
            class="story-switcher__sidebar--right ml-md-5"
          >
            <v-list dense class="story-switcher__list">
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
                  {{ sidebar.title }}
                </v-list-item>
                <v-list-item class="story-switcher__search mb-4 mt-2">
                  <Search
                    :searchTerm="search"
                    @setSearch="searchRecords"
                  />
                </v-list-item>
                <v-list-item
                  v-for="sidebarItem in filteredRecords"
                  :key="sidebarItem.id"
                  class="story-switcher__link"
                  :class="{'story-switcher__link--active': selectedItem.id === sidebarItem.id}"
                  @click="selectFilter(sidebarItem.filters)"
                >
                  <v-icon v-if="sidebarItem.icon" class="story-switcher__icon">
                    {{ sidebarItem.icon }}
                  </v-icon>
                  <Avatar
                    v-else
                    :src="sidebarItem.avatar"
                    size="small"
                  />
                  <span class="pl-3" v-text="sidebarItem.name" />
                </v-list-item>
            </v-list>
          </v-col>
        </v-row>
      </div>
    </v-menu>
  </div>
 
</template>

<script>
import {mapActions, mapState} from 'vuex'
import Avatar from '../../Elements/Avatar'
import Search from '../../Elements/Forms/Search'

export default {
  components: {
    Avatar,
    Search
  },
  data: () => ({
    displaySwitcher: false,
    sidebar: {},
    search: ''
  }),
  computed: {
    ...mapState({
      filters: state => state.stories.filters,
      sorting: state => state.stories.sorting,
      families: state => state.families.simpleList.families
    }),
    storySwitcherItems() {
      return [
        {
          title: '',
          items: [
            {
              id: 'all',
              name: this.$i18n.t('stories.filters.all_stories'),
              icon: 'mdi-text-box-outline',
              filters: {}
            }
          ]
        },
        {
          title: this.$i18n.t('stories.filters.my_stories'),
          divider: true,
          items: [
            {
              id: 'private',
              name: this.$i18n.t('stories.filters.private_stories'),
              icon: 'mdi-lock-outline',
              filters: {
                publicationVisibility: 'private_stories',
              }
            },
            {
              id: 'shared',
              name: this.$i18n.t('stories.filters.shared_stories'),
              icon: 'mdi-redo',
              filters: {
                publicationVisibility: 'shared_stories',
              }
            }
          ]
        },
        {
          title: this.$i18n.t('stories.filters.all_communities'),
          more: true,
          items: this.families.map((item) => ({
            id: item.id,
            name: item.attributes.name,
            avatar: item.attributes.coverUrl || '',
            filters: {
              familyId: item.id
            }
          }))
        }
      ]
    },
    selectedItem() {
      let activeItem
      const filteredKey = this.filters.familyId ? 'familyId' : 'publicationVisibility'
      for (const group of this.storySwitcherItems) {
        activeItem = group.items.find((item) => {
          return item.filters[filteredKey] === this.filters[filteredKey]
        })
        if (activeItem) break;
      }
      return activeItem || this.storySwitcherItems[0].items[0]
    },
    sidebarIsActive() {
      return !!this.sidebar.title
    },
    filteredRecords() {
      return this.search ? this.sidebar.items.filter((item) => item.name.toLowerCase().includes(this.search.toLowerCase())) : this.sidebar.items
    }
  },
  methods: {
    ...mapActions({
      setStoryFilters: 'stories/setStoryFilters',
      clearStoryFilters: 'stories/clearStoryFilters'
    }),
    selectedGroup(group) {
      return this.sidebar.title === group.title
    },
    toggleSwitcher() {
      this.sidebar = {}
      this.displaySwitcher = !this.displaySwitcher
    },
    toggleSidebar(group) {
      this.sidebar = group.title === this.sidebar.title ? {} : group
    },
    selectFilter(filters) {
      this.displaySwitcher = false
      this.clearStoryFilters()
      this.setStoryFilters(filters)
      this.$router.replace({ query: {
          ...filters,
          ...this.sorting
        }
      }).catch(()=>{})
    },
    searchRecords({query}) {
      this.search = query
    }
  }
}
</script>

<style lang="scss" scoped>
  .story-switcher {
    border-radius: 5px;
    box-shadow: none;
    &:before,
    &:after {
      content: "";
      position: absolute;
      width: 0;
      height: 0;
      border-style: solid;
      border-color: transparent;
      border-bottom: 0;
    }
    &:before {
      top: 0;
      left: 27px;
      width: 0;
      height: 0;
      border-left: 8px solid transparent;
      border-right: 8px solid transparent;
      border-bottom: 8px solid $color-primary;
    }
    &:after {
      top: 1px;
      left: 28px;
      width: 0;
      height: 0;
      border-left: 7px solid transparent;
      border-right: 7px solid transparent;
      border-bottom: 7px solid $color-dark-white;
    }
    &__activator {
      display: flex;
      &::v-deep .v-input__slot {
        cursor: pointer !important;
      }
    }
    &__wrapper {
      background: $color-dark-white;
      border: 1px solid $color-primary;
      border-radius: 5px;
      margin-top: 10px;
      overflow: hidden;
      padding-top: 20px;
    }
    &__list {
      background-color: transparent;
      max-height: 80vh;
      overflow-y: auto;
    }
    &__title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      font-weight: bold;
      font-size: 14px;
      line-height: 26px;
      color: $color-primary !important;
    }
    &__title {
      padding-left: 30px;
    }
    &__link {
      min-height: 32px;
      padding-left: 32px;
      font-weight: bold;
      font-size: 16px;
      color: #4B4B4B;
      &--active.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
        background-color: #FCD0C4;
        color: $color-primary !important;
      }
      &--more.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
        font-weight: bold;
        font-size: 16px;
        line-height: 26px;
        color: $color-primary !important;
        justify-content: flex-end;
      }
    }
    &__sidebar-title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      padding-left: 30px;
      font-weight: bold;
      font-size: 18px;
      line-height: 26px;
      color: $color-primary !important;
    }
    &__search {
      padding-left: 32px;
    }
    &__sidebar {
      &--left,
      &--right {
        min-width: 308px;
        min-height: 300px;
        max-height: 700px;
        overflow-y: auto;
      }
    }
    &__back-button {
      position: absolute;
      right: 16px;
      z-index: 1;
    }
  }
</style>
