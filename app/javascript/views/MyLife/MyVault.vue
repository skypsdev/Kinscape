<template>
  <VaultItems
    :get-more-items="getMoreVaultItems"
    :get-items="getItems"
  />
</template>

<script>
import { mapActions, mapState, mapGetters } from 'vuex'

import VaultItems from '@/components/Vault/VaultItems.vue'
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin'

export default {
  components: {
    VaultItems
  },
  mixins: [vaultIdMixin],
  beforeRouteLeave(to, from, next) {
    this.clearVault()
    this.clearVaultFilters()
    this.clearVaultSorting()
    next()
  },
  computed: {
    ...mapGetters({
      hasMorePages: 'vaults/hasMorePages'
    }),
    ...mapState({
      vault: state => state.vaults.vault
    })
  },
  methods: {
    ...mapActions({
      getVaultItems: 'vaults/getVaultItems',
      clearVault: 'vaults/clearVault',
      setVaultFilters: 'vaults/setVaultFilters',
      clearVaultFilters: 'vaults/clearVaultFilters',
      clearVaultSorting: 'vaults/clearVaultSorting',
      setVaultSorting: 'vaults/setVaultSorting'
    }),
    getItems() {
      this.clearVault()
      this.getVaultItems({
        vaultId: this.vaultId,
        params: { page: 1, ...this.getShowcaseOptions() }
      })
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
        result.showcase = true
      }

      return result
    },
    async getMoreVaultItems($state) {
      try {
        await this.getVaultItems({ vaultId: this.vaultId })
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    }
  }
}
</script>
<style lang="scss">
@import "@/assets/styles/components/vaultMoveDialog";
@import "@/assets/styles/components/vaultDetailsBtn";
</style>
