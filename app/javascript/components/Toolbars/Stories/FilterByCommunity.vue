<template>
  <div id="intro-stories-filter-stories">
    <v-menu
      bottom
      offset-y
      nudge-left="100"
      v-model="displaySwitcher"
      content-class="story-switcher"
      :close-on-content-click="false"
    >
      <template v-slot:activator="{ attrs }">
        <div class="story-switcher__activator" @click="toggleSwitcher">
          <Tooltip
            position="bottom right"
            name="storyFilters"
            :icons="['mdi-text-box-outline']"
            :title="$i18n.t('tooltips.story_filters_title')"
            :description="$i18n.t('tooltips.story_filters_description')"
          >
            <template #activator="{ attrs: tooltipAttrs }">
              <v-btn
                rounded
                outlined
                color="primary"
                elevation="0"
                class="mx-1"
                :large="isMobile"
                v-bind="{ ...attrs, ...tooltipAttrs }"
              >
                <Avatar
                  v-if="selectedItem.avatar"
                  :src="selectedItem.avatar"
                  class="mr-1"
                  size="small"
                />
                <v-icon v-else class="mr-1">{{ selectedItem.icon }}</v-icon>
                {{ selectedItem.name }}
                <v-icon>{{
                  displaySwitcher ? "mdi-chevron-up" : "mdi-chevron-down"
                }}</v-icon>
              </v-btn>
            </template>
          </Tooltip>
        </div>
      </template>

      <div class="story-switcher__wrapper">
        <v-row no-gutters>
          <v-col
            class="story-switcher__sidebar--left"
            :class="{ 'hidden-sm-and-down': sidebarIsActive }"
          >
            <v-list dense class="story-switcher__list pb-0">
              <div
                v-for="(group, index) in storySwitcherItems"
                :key="index"
                class="pb-4"
              >
                <v-list-item v-if="group.title" class="story-switcher__title">
                  {{ group.title }}
                </v-list-item>

                <v-list-item
                  v-for="item in group.items.slice(0, 3)"
                  :key="item.id"
                  class="story-switcher__link"
                  :class="{
                    'story-switcher__link--active': selectedItem.id === item.id,
                  }"
                  @click="selectFilter(item.filters)"
                >
                  <v-icon v-if="item.icon" class="story-switcher__icon">
                    {{ item.icon }}
                  </v-icon>
                  <Avatar v-else :src="item.avatar" size="small" />
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
                    <v-icon color="primary">mdi-chevron-left</v-icon>
                    <span class="mr-2">{{ $i18n.t("stories.show_less") }}</span>
                  </template>
                  <template v-else>
                    {{ $i18n.t("stories.show_all") }}
                    <v-icon color="primary">mdi-chevron-right</v-icon>
                  </template>
                </v-list-item>

                <v-divider v-if="group.divider" class="mt-4 mx-2" />
              </div>
            </v-list>
          </v-col>

          <FilterByCommunitySearchSidebar
            v-if="sidebarIsActive"
            :toggle-sidebar="toggleSidebar"
            :select-filter="selectFilter"
            :title="sidebar.title"
            :items="$$(sidebar,'items') || []"
            :selected-item-id="$$(selectedItem,'id')"
          />
        </v-row>
      </div>
    </v-menu>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import breakpointsMixin from '@/mixins/breakpointsMixin'
import Avatar from '@/components/Elements/Avatar'
import Tooltip from '@/components/Elements/Tooltip.vue'
import FilterByCommunitySearchSidebar from "@/components/Toolbars/Stories/FilterByCommunitySearchSidebar.vue"

export default {
  components: {
    Avatar,
    Tooltip,
    FilterByCommunitySearchSidebar
  },
  mixins: [breakpointsMixin],
  data: () => ({
    displaySwitcher: false,
    sidebar: {}
  }),
  computed: {
    ...mapState({
      filters: state => state.stories.filters,
      sorting: state => state.stories.sorting,
      families: state => state.families.simpleList.families,
      followings: state => state.myPeople.followings.data,
      personalFamilyId: state => state.core.user.familyId
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
                hideAuthor:true
              }
            },
            {
              id: 'shared',
              name: this.$i18n.t('stories.filters.shared_stories'),
              icon: 'mdi-redo',
              filters: {
                publicationVisibility: 'shared_stories',
                hideAuthor:true
              }
            },
            /* --------------------------------- MY LIFE -------------------------------- */
            {
              id: 'my-life',
              name: this.$i18n.t('stories.filters.my_life_stories'),
              icon: 'mdi-account',
              filters: {
                familyId: this.personalFamilyId,
                hideAuthor:true
              }
            }
          ]
        },

        /* ------------------------------- COMMUNITIES ------------------------------ */
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
        },

        /* -------------------------------- MY PEOPLE ------------------------------- */

        {
          title: this.$i18n.t('stories.filters.all_my_people'),
          more: true,
          items: this.followings.map((item) => ({
            id: item.id,
            name: item.attributes.nickname,
            avatar: item.attributes.avatarUrl || '',
            filters: {
              hideAuthor:true,
              familyId: item.attributes.familyId
            }
          }))
        }
      ]
    },
    selectedItem() {
      let activeItem
      let filteredKey

      if (this.filters['familyId']) filteredKey = 'familyId'
      else filteredKey = 'publicationVisibility'

      for (const group of this.storySwitcherItems) {
        activeItem = group.items.find((item) => {
          return item.filters[filteredKey] == this.filters[filteredKey]
        })
        if (activeItem) break;
      }
      return activeItem || this.storySwitcherItems[0].items[0]
    },
    sidebarIsActive() {
      return !!this.sidebar?.title
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
      this.sidebar = group.title === this.sidebar?.title ? {} : group
    },
    selectFilter(filters) {
      this.displaySwitcher = false

      this.clearStoryFilters()
      this.setStoryFilters(filters)

      this.$router.replace({
        query: {
          ...filters,
          ...this.sorting
        }
      })
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
    color: $tertiary;
    &--active.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      background-color: $primary-lightest;
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
