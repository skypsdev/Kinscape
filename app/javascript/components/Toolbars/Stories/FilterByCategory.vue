<template>
  <div>
    <v-menu
      bottom
      offset-y
      v-model="displaySwitcher"
      content-class="category-switcher"
      :close-on-content-click="false"
    >
      <template v-slot:activator="{ attrs }">
        <div
          class="category-switcher__activator"
          @click="displaySwitcher = !displaySwitcher"
        >
          <v-text-field
            clearable
            placeholder="Categories"
            :value="filterHasValue ? 'Categories' : null"
            dense
            solo
            flat
            readonly
            hide-details
            single-line
            :background-color="filterHasValue ? 'primary' : 'light_grey'"
            :dark="filterHasValue"
            clear-icon="mdi-close-circle-outline"
            type="text"
            class="category-switcher__input"
            :append-icon="displaySwitcher ? 'mdi-menu-up' : 'mdi-menu-down'"
            v-bind="attrs"
            @click:clear="selectCategory()"
          />
        </div>
      </template>
      <div class="category-switcher__wrapper">
        <v-row no-gutters>
          <v-col class="category-switcher__sidebar--left pb-3">
            <Search
              class="px-6 pt-4 pb-2"
              :searchTerm="search"
              @setSearch="searchCategory"
            />
            <div class="px-5 pt-3">
              <v-chip
                v-for="item in filteredCategories"
                :key="item.name + item.id"
                class="category-switcher__button mx-1 mt-1 mb-2"
                :class="{'category-switcher__button--selected': item.selected}"
                :dark="item.selected"
                :color="item.selected ? '#8B78FE' : 'secondary_lightest'"
                label
                @click="selectCategory(item.name)"
              >
                <v-icon v-if="item.selected">
                  mdi-check-circle-outline
                </v-icon>
                {{ item.name }}
              </v-chip>
            </div>
          </v-col>
        </v-row>
      </div>
    </v-menu>
  </div>
</template>
<script>
import {mapActions, mapState} from 'vuex'
import Search from '../../Elements/Forms/Search'

export default {
  components: {
    Search
  },
  data: () => ({
    displaySwitcher: false,
    search: ''
  }),
  computed: {
    ...mapState({
      filters: state => state.stories.filters,
      allCategories: store => store.stories.allCategories
    }),
    filteredCategories() {
      let filteredCategories = this.allCategories || []
      filteredCategories = filteredCategories.map((item, index) => ({
        id: index,
        name: item.text,
        selected: this.filterHasValue ? this.filters.categories.includes(item.text) : false
      }))
      if (!this.search) return filteredCategories.slice(0,8)
      return filteredCategories
          .filter((item) => item.name.toLowerCase().includes(this.search.toLowerCase()))
          .slice(0,8)
    },
    filterHasValue() {
      return !!this.filters.categories?.length
    }
  },
  methods: {
    ...mapActions({
      setStoryFilters: 'stories/setStoryFilters'
    }),
    searchCategory(searchQuery) {
      this.search = searchQuery.query
    },
    selectCategory(name = '') {
      let categories = []
      if (name) {
        categories = this.filters.categories
        if (typeof categories === 'string') categories = [categories]
        if (categories.includes(name)) {
          categories = categories.filter((el) => el !== name)
        } else {
          categories.push(name)
        }
      }
      this.$router.replace({ query: {
          ...this.$route.query,
          categories
        } }).catch(()=>{})
      this.setStoryFilters({categories})
    }
  }
}
</script>
<style lang="scss" scoped>
.category-switcher {
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
    width: 200px;
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
  &__button {
    border-radius: 80px !important;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;
    color: $color-tertiary;
    max-height: 30px;
    &--selected {
      color: white !important;
      padding-left: 4px;
      &::v-deep .v-icon {
        margin-right: 10px;
        font-size: 24px;
        height: 24px;
        width: 24px;
      }
    }
  }
  &__sidebar--left {
    max-width: 308px;
    max-height: 700px;
    overflow-y: auto;
  }
}
</style>
