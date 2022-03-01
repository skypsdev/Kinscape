<template>
  <VaultItems :get-items="getItems" />
</template>

<script>
import { mapActions } from 'vuex'

import VaultItems from '@/components/Vault/VaultItems.vue'
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin'
export default {
  name: 'CommunityBoxVault',
  components: { VaultItems },
  mixins: [vaultIdMixin],
  beforeRouteLeave(to, from, next) {
    this.clearVault()
    this.clearVaultFilters()
    this.clearVaultSorting()
    next()
  },
  methods: {
    ...mapActions({
      getFamily: 'families/getCommunity',
      clearVault: 'vaults/clearVault',
      clearVaultFilters: 'vaults/clearVaultFilters',
      clearVaultSorting: 'vaults/clearVaultSorting',
      getBox: 'vaults/getBox'
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

      const { boxId } = this.$route.params
      const { vaultId } = this

      this.clearVault()
      this.getBox({ vaultId, boxId })
    },
  }
}
</script>
<style lang="scss">
  @import '@/assets/styles/components/vaultMoveDialog';
  @import '@/assets/styles/components/vaultDetailsBtn';
</style>