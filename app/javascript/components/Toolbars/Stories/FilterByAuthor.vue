<template>
  <div>
    <v-menu
      bottom
      offset-y
      v-model="displaySwitcher"
      content-class="author-switcher"
      :close-on-content-click="false"
    >
      <template v-slot:activator="{ attrs }">
        <div
          class="author-switcher__activator"
          :style="{width: filterWidth + 'px'}"
          @click="displaySwitcher = !displaySwitcher"
        >
          <v-text-field
            :value="selectedAuthor.name | truncate(25)"
            clearable
            placeholder="Author"
            dense
            solo
            flat
            readonly
            hide-details
            single-line
            :background-color="!!selectedAuthor.name ? 'primary' : 'light_grey'"
            :dark="!!selectedAuthor.name"
            clear-icon="mdi-close-circle-outline"
            type="text"
            class="author-switcher__input"
            :append-icon="displaySwitcher ? 'mdi-menu-up' : 'mdi-menu-down'"
            v-bind="attrs"
            @click:clear="selectAuthor()"
          />
        </div>
      </template>
      <div class="author-switcher__wrapper">
        <v-row no-gutters>
          <v-col class="author-switcher__sidebar--left pb-3">
            <Search
              class="px-6 pt-4 pb-2"
              :searchTerm="search"
              @setSearch="searchAuthor"
            />
            <v-list dense class="author-switcher__list pb-0">
              <v-list-item
                v-for="item in filteredAuthors"
                :key="item.userId"
                class="author-switcher__link"
                :class="{'author-switcher__link--active': selectedAuthor.userId === item.userId}"
                @click="selectAuthor(item.userId)"
              >
                <Avatar
                  :src="item.avatar"
                  size="small"
                />
                <span class="pl-3">
                  {{ item.name }}
                </span>
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
import filters from '../../../utils/filters'

export default {
  filters: {
    truncate: filters.truncate,
  },
  components: {
    Avatar,
    Search
  },
  data: () => ({
    displaySwitcher: false,
    search: ''
  }),
  computed: {
    ...mapState({
      allFamilies: state => state.families.simpleList.families,
      allMembers: state => state.families.simpleList.members,
      filters: state => state.stories.filters,
      currentUser: state => state.core.user,
    }),
    filteredAuthors () {
      let filteredMembers = this.allMembers.map((item) => ({
        id: item.id,
        name: item.attributes?.nickname || '',
        userId: item.attributes?.userId,
        avatar: item.attributes?.avatarUrl || ''
      }))
      const getUniqueBy = (arr, prop) => {
        const set = new Set;
        return arr.filter(o => !set.has(o[prop]) && set.add(o[prop]));
      }
      let uniqMembers = []
      if (this.filters.familyId && this.allFamilies.length) {
        const selectedFamily = this.allFamilies.find(f => f.id === this.filters.familyId)
        const filteredMemberIds = selectedFamily ? selectedFamily.relationships.kinships.data.map((u) => u.id) : []
        uniqMembers = filteredMembers.filter((member) => filteredMemberIds.includes(member.id))
      }
      else {
        uniqMembers = getUniqueBy(filteredMembers, 'userId')
      }

      if (!this.search) return uniqMembers
      return uniqMembers.filter((item) => item.name.toLowerCase().includes(this.search.toLowerCase()))
    },
    selectedAuthor() {
      return this.filteredAuthors.find((author) => author.userId === this.filters.authorId) || {}
    },
    filterWidth() {
      const length = this.selectedAuthor?.name?.length || 0
      if (!length || length <= 16) return 200
      if (length > 25) return 284
      return (length - 15) * 8 + 200
    }
  },
  methods: {
    ...mapActions({
      setStoryFilters: 'stories/setStoryFilters',
    }),
    searchAuthor({query}) {
      this.search = query
    },
    selectAuthor(id = '') {
      this.displaySwitcher = false
      this.$router.replace({ query: {
        ...this.$route.query,
        authorId: id
      } }).catch(()=>{})
      this.setStoryFilters({authorId: id})
    }
  }
}
</script>

<style lang="scss" scoped>
.author-switcher {
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
  &__activator::v-deep {
    .v-text-field--solo > .v-input__control > .v-input__slot {
      cursor: pointer !important;
      padding-right: 4px !important;
    }
    .v-text-field .v-input__append-inner {
      margin: 0 !important;
      padding: 0;
      .v-input__icon {
        opacity: 1 !important;
      }
    }
    .v-input__icon--clear {
      margin-left: 4px;
    }
    input {
      font-family: Enriqueta;
      font-style: normal;
      font-weight: bold;
      font-size: 16px;
      line-height: 21px;
      &::-webkit-input-placeholder {
        opacity: 1 !important;
        color: $color-tertiary !important;
        font-family: Enriqueta;
        font-style: normal;
        font-weight: bold;
        font-size: 16px;
        line-height: 21px;
      }
    }
  }
  &__wrapper {
    background: $color-dark-white;
    border: 1px solid $color-primary;
    border-radius: 5px;
    margin-top: 10px;
    overflow: hidden;
  }
  &__list {
    background-color: transparent;
    max-height: 80vh;
    overflow-y: auto;
  }
  &__title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 26px;
    color: $color-primary !important;
  }
  &__link {
    padding: 0 24px;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 26px;
    color: #4B4B4B;
    &--active.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      background-color: #FCD0C4;
      color: $color-primary !important;
    }
  }
  &__sidebar--left {
    min-width: 280px;
    max-height: 700px;
    overflow-y: auto;
  }
}
</style>
