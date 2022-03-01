<template>
  <v-btn
    class="ml-1"
    rounded
    outlined
    color="primary"
    elevation="0"
    min-width="160"
    :disabled="isDisabled"
    @click="onCopyClick"
  >
    <v-icon left>mdi-content-copy</v-icon>
    {{ $i18n.t('vaults.nav.buttons.copy') }}
  </v-btn>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
export default {
  mixins: [vaultPermissions],
  computed: {
    ...mapState({
      vault: state => state.vaults.vault,
      selectedVaultFileIds: state => state.vaults.selectedVaultFileIds
    }),
    isDisabled() {
      return this.selectedVaultItems.every(this.isAsset) === false
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    onCopyClick() {
      this.setDialog({
        component: 'VaultCopyDialog',
        size: 'big'
      })
    }
  }
}
</script>
