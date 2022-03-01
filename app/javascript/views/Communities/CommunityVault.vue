<template>
  <VaultItems
    :get-more-items="getMoreVaultItems"
    :get-items="getItems"
  />
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

import VaultItems from '@/components/Vault/VaultItems.vue'
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin'

export default {
  components: { VaultItems },
  mixins: [vaultIdMixin],
  beforeRouteLeave(to, from, next) {
    this.clearVault()
    this.clearVaultFilters()
    this.clearVaultSorting()
    next()
  },
  computed: mapGetters({
    hasMorePages: 'vaults/hasMorePages'
  }),
  methods: {
    ...mapActions({
      getFamily: 'families/getCommunity',
      clearVault: 'vaults/clearVault',
      clearVaultFilters: 'vaults/clearVaultFilters',
      clearVaultSorting: 'vaults/clearVaultSorting',
      getVault: 'vaults/getVault'
    }),
    async fetchCommunity() {
      if (this.community.id !== this.$route.params.id) {
        await this.getFamily({
          id: this.$route.params.id,
          options: {}
        })
      }
    },
    async getItems() {
      await this.fetchCommunity()

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