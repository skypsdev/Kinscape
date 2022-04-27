<template>
  <div>
    <slot v-if="!isMobile">
      <v-btn
        v-if="bigButton"
        large
        rounded
        color="primary"
        elevation="0"
        min-width="170"
        :disabled="disabled"
        class="ma-2"
        @click="openFileUpload"
      >
        {{ $i18n.t("vaults.empty.upload_content") }}
      </v-btn>
      <v-btn
        v-else
        rounded
        outlined
        color="primary"
        elevation="0"
        min-width="114"
        :disabled="disabled"
        @click="openFileUpload"
      >
        <v-icon left>mdi-upload-outline</v-icon>
        {{ $i18n.t("vaults.nav.buttons.upload_to_vault") }}
      </v-btn>
    </slot>
    <slot v-else>
      <v-btn
        color="primary"
        fab
        small
        rounded
        outlined
        elevation="0"
        :disabled="disabled"
        @click="openFileUpload"
      >
        <v-icon>mdi-upload-outline</v-icon>
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
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
import breakpointsMixin from '@/mixins/breakpointsMixin'

export default {
  mixins: [vaultIdMixin, vaultPermissions, breakpointsMixin],
  props: {
    bigButton: {
      type: Boolean,
      default: false
    }
  },
  data: () => ({
    file: null
  }),
  computed: {
    ...mapState('vaults', ['loading', 'vault']),
    disabled() {
      return !this.canAddBoxesToVault(this.vault) || this.loading
    },
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      uploadVaultFile: 'vaults/uploadVaultFile'
    }),
    async handleImageChange(files) {
      try {
        const { boxId } = this.$route.params;

        await this.uploadVaultFile({
          vaultId: this.vaultId,
          boxId: boxId || null,
          files
        })
      } catch (err) {
        console.error(err)
      }
    },
    openFileUpload() {
      this.setDialog({
        component: 'UploadDialog',
        customSize: '800px',
        customClass: 'upload-dialog',
        data: {
          callback: this.handleImageChange,
          editName: true,
          multiple: true
        },
      })
    }
  }
}
</script>
