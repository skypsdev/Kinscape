<template>
  <div class="vault">
    <v-container class="vault__grid">
      <h1
        class="grid__title mt-12"
        v-text="vaultTitle"
      />
      <template v-if="hideEmptyState">
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
    </v-container>
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
    },
    hideEmptyState() {
      return this.vault.items.length || this.vault.box.id || this.$route.query.query
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

.vault {
  &__wrap {
    margin-top: 23px;
    padding-bottom: 24px;
  }
  
  &__grid {
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
