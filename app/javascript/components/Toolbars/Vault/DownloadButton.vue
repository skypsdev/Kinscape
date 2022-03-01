<template>
  <v-btn
    rounded
    outlined
    color="primary"
    elevation="0"
    min-width="160"
    download
    :disabled="!selectedVaultFileIds.length"
    :href="downloadLink"
  >
    <v-icon left>mdi-download-outline</v-icon>
    {{ $i18n.t('vaults.nav.buttons.download_from_vault') }}
  </v-btn>
</template>

<script>
import qs from 'qs'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

export default {
  name: 'DownloadButton',
  mixins: [vaultIdMixin],
  computed: {
    selectedVaultFileIds() {
      return this.$store.getters['vaults/selectedIds'].filesIds.map(Number);
    },
    downloadLink() {
      const params = qs.stringify({ ids: this.selectedVaultFileIds }, { arrayFormat: 'brackets', encodeValuesOnly: true })
      return `/vaults/${this.vaultId}/download?${params}`
    }

  }
}
</script>
