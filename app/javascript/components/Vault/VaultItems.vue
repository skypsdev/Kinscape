<template>
  <div class="vault">
    <div class="vault__grid">
      <h1
        class="vault__title mt-12"
        v-text="vaultTitle"
      />
      <template v-if="vault.items.length || $route.query.query">
        <div class="vault__toolbar">
          <Search
            class="vault__search mt-6"
            :placeholder="$i18n.t('vault.search_in_vault')"
            :searchTerm="$route.query.query"
            @setSearch="handleFilter"
          />
          <div class="d-flex vault__wrap">
            <VaultBreadcrumbs :vault="vault" />
            <v-spacer />
            <Sorting
              :sorting-action="setVaultSorting"
              class="vault__sorting"
              id="vault-sorting"
            />
          </div>
        </div>
        <div
          v-if="vault.items.length || $route.query.query"
          class="vault__items d-flex flex-wrap justify-start"
        >
          <div
            v-for="item in vault.items"
            :key="item.id + item.attributes.itemType"
            class="px-2 pb-2"
          >
            <VaultItem :item="item" />
          </div>
        </div>
        <infinite-loading
          v-if="hasMorePages && getMoreItems"
          class="mb-12"
          spinner="spiral"
          force-use-infinite-wrapper
          @infinite="getMoreItems"
        >
          <div slot="no-more" />
        </infinite-loading>
      </template>
      <div v-else-if="!isLoading">
        <EmptyState />
      </div>
    </div>
  </div>

</template>

<script>
import { mapState, mapActions, mapGetters } from "vuex"

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

import EmptyState from "@/components/Vault/EmptyState"
import Search from "@/components/Elements/Forms/Search.vue"
import Sorting from "@/components/Toolbars/Stories/Sorting"
import VaultBreadcrumbs from "@/components/Vault/VaultBreadcrumbs"
import VaultItem from "@/components/Vault/VaultItem"
export default {
  name: "VaultItems",
  components: {
    VaultItem,
    VaultBreadcrumbs,
    Sorting,
    Search,
    EmptyState
  },
  mixins: [vaultIdMixin],
  props: {
    getItems: {
      type: Function,
      default: null
    },
    getMoreItems: {
      type: Function,
      default: null
    }
  },
  computed: {
    ...mapState({
      isLoading: state => state.vaults.loading,
      vault: state => state.vaults.vault,
      community: state => state.families.community
    }),
    ...mapGetters({
      hasMorePages: 'vaults/hasMorePages'
    }),
    vaultTitle() {
      return this.insideMyVaultView ? this.$i18n.t('vaults.private.label') :
        this.$i18n.t('vaults.family.label', { community: this.community.name })
    }
  },
  watch: {
    '$route.query': 'getItems'
  },
  created() {
    const { sortBy, sortDirection, query } = this.$route.query

    if (sortBy && sortDirection) {
      this.setVaultSorting({ sortBy, sortDirection })
    }

    if (query !== undefined) {
      this.setVaultFilters({ query })
    }

    this.getItems()
  },
  methods: {
    ...mapActions({
      setVaultFilters: 'vaults/setVaultFilters',
      setVaultSorting: 'vaults/setVaultSorting'
    }),
    handleFilter(searchQuery) {
      const query = searchQuery.query.trim()

      const queryCopy = { ...this.$route.query, query }

      if (queryCopy.query == '') delete queryCopy.query

      this.$router.replace({
        query: queryCopy
      })

      this.setVaultFilters({ query })
    }
  }
};
</script>

<style lang="scss" scoped>
@mixin container-grid-size() {
  $cover_width: 288px;
  $min_col_width: 600px;
  width: $cover_width;
  @for $i from 0 to 6 {
    @media screen and (min-width: $min_col_width + $cover_width * $i) {
      width: $cover_width * ($i + 2);
      @if $i > 1 {
        padding: 0 155px;
      }
    }
  }
}

.vault {
  &__wrap {
    margin-top: 23px;
    padding-bottom: 24px;
  }
  &__title {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    letter-spacing: -0.02em;
    color: $color-tertiary;
  }
  &__grid {
    padding: 0 8px;
    margin: 0 auto;
    @include container-grid-size();
  }
  &__items {
    margin-left: -8px;
    margin-right: -8px;
  }
  &__search {
    max-width: 300px;
  }
  &__sorting {
    max-width: 300px;
  }
}
</style>

<style lang="scss">
.vault__search {
  .v-input__slot {
    padding: 0px 11px !important;
  }
  .v-input__prepend-inner {
    margin-top: 8px !important;
    margin-right: 2px;
  }
  .v-input__icon {
    min-width: 17.5px;
    width: 17.5px;
    height: 17.5px;
  }
  .v-label {
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    display: flex;
    align-items: center;
    color: $primary-grey;
  }
}
</style>
