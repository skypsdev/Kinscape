<template>
  <div class="d-flex flex-row align-center sorting-switcher">
    <div class="mr-3 hidden-sm-and-down text-no-wrap sorting-switcher__title" v-text="$i18n.t('stories.sorting.sort_by')"/>
    <v-menu
      bottom
      offset-y
      content-class="sorting-switcher"
    >
      <template v-slot:activator="{ on, attrs }">
        <div class="sorting-switcher__activator">
          <v-text-field
            :value="selectedParameter.text"
            dense
            solo
            flat
            readonly
            hide-details
            single-line
            background-color="light_grey"
            type="text"
            class="sorting-switcher__input"
            :append-icon="attrs['aria-expanded'] !== 'false' ? 'mdi-menu-up' : 'mdi-menu-down'"
            v-bind="attrs"
            v-on="on"
          />
        </div>
      </template>
      <div class="sorting-switcher__wrapper">
        <v-list dense class="sorting-switcher__list">
          <v-list-item
            v-for="option in sortParameters"
            :key="option.id"
            class="sorting-switcher__link"
            :class="{'sorting-switcher__link--active': selectedParameter.id === option.id}"
            @click="changeSorting(option.params)"
          >
            {{ option.text}}
          </v-list-item>
        </v-list>
      </div>
    </v-menu>
  </div>
</template>

<script>
export default {
  props:{
    sortingAction: {
      type: Function,
      default: null,
      required:true
    }
  },
  computed: {
    sortParameters() {
      return [
        {
          id: 'updated',
          text: this.$i18n.t('stories.sorting.most_recently_updated'),
          params: {
            sortBy: 'updated_at',
            sortDirection: 'DESC'
          }
        },
        {
          id: 'newest',
          text: this.$i18n.t('stories.sorting.date_created_newest'),
          params: {
            sortBy: 'created_at',
            sortDirection: 'DESC'
          }
        },
        {
          id: 'oldest',
          text: this.$i18n.t('stories.sorting.date_created_oldest'),
          params: {
            sortBy: 'created_at',
            sortDirection: 'ASC'
          }
        },
        {
          id: 'name',
          text: this.$i18n.t('stories.sorting.name_a_z'),
          params: {
            sortBy: 'title',
            sortDirection: 'ASC'
          }
        }
      ]
    },
    selectedParameter() {
      const {sortBy, sortDirection} = this.sortingQuery

      return this.sortParameters.find(({params}) =>
        params.sortBy === sortBy &&
        params.sortDirection === sortDirection
      )
    },
    sortingQuery(){
      return {
          sortBy: this.$route.query?.sortBy || "created_at",
          sortDirection: this.$route.query?.sortDirection || "DESC"
      }
    }
  },
  methods: {
    changeSorting(params = {}) {
      this.$router.replace({ query: {
        ...this.$route.query,
        ...params,
      } })
      this.sortingAction(params)
    }
  }
}
</script>
<style lang="scss">
.sorting-switcher {
  &__title {
    font-family: Lato;
    font-size: 16px;
    display: flex;
    align-items: center;
    color: black;
  }

  &__input input {
    padding: 0 !important;
  }

  .v-icon {
    color: $color-tertiary;
  }
}
</style>