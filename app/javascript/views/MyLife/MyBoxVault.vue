<template>
  <VaultItems :get-items="getItems" />
</template>

<script>
import { mapActions } from 'vuex'

import VaultItems from '@/components/Vault/VaultItems.vue'
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin'
export default {
  name: 'MyBoxVault',
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
      clearVault: 'vaults/clearVault',
      clearVaultFilters: 'vaults/clearVaultFilters',
      clearVaultSorting: 'vaults/clearVaultSorting',
      getBox: 'vaults/getBox'
    }),
    getItems() {
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