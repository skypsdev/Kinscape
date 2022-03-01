<template>
  <label @click="!loading ? $refs.fileInput.$refs.input.click() : {}">
    <slot>
      <v-btn
        rounded
        outlined
        color="primary"
        elevation="0"
        min-width="114"
        :disabled="loading || disabled"
      >
        <v-icon left>mdi-upload-outline</v-icon>
        {{ $i18n.t('vaults.nav.buttons.upload_to_vault') }}
      </v-btn>
    </slot>
    <v-file-input
      ref="fileInput"
      class="hidden-input-file"
      hide-input
      prepend-icon=""
      v-model="file"
      :disabled="loading"
      @change="handleImageChange"
    >
    </v-file-input>
  </label>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
export default {
  mixins: [vaultIdMixin, vaultPermissions],
  data: () => ({
    file: null
  }),
  computed: {
    ...mapState('vaults', ['loading']),
    disabled() {
      return this.canAddBoxesToVault() == false
    },
  },
  methods: {
    ...mapActions({
      uploadVaultFile: 'vaults/uploadVaultFile'
    }),
    handleImageChange() {
      if (this.file) {
        const { boxId } = this.$route.params;

        this.uploadVaultFile({
          vaultId: this.vaultId,
          boxId: boxId || null,
          file: this.file
        })
      }
    }
  }
}
</script>
