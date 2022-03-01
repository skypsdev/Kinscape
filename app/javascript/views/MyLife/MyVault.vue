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
      getVault: 'vaults/getVault',
      clearVault: 'vaults/clearVault',
      setVaultFilters: 'vaults/setVaultFilters',
      clearVaultFilters: 'vaults/clearVaultFilters',
      clearVaultSorting: 'vaults/clearVaultSorting',
      setVaultSorting: 'vaults/setVaultSorting'
    }),
    getItems() {
      this.clearVault()
      this.getVault({
        vaultId: this.vaultId,
        params: { page: 1 }
      })
    },
    async getMoreVaultItems($state) {
      try {
        await this.getVault({ vaultId: this.vaultId })
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
  @import '@/assets/styles/components/vaultMoveDialog';
  @import '@/assets/styles/components/vaultDetailsBtn';
</style>