<template>
  <DialogContent>
    <template v-slot:content>
      <div
        class="dialog-description my-12"
        v-html="$i18n.t('vaults.attachments.delete.description', {name: fileNames})"
      />
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          large
          rounded
          outlined
          color="primary"
          elevation="0"
          class="ma-2"
          min-width="170"
          @click="closeDialog()"
        >
          {{ $i18n.t('confirmation_dialog.cancel') }}
        </v-btn>
        <v-btn
          large
          rounded
          color="primary"
          elevation="0"
          class="ma-2"
          min-width="170"
          :disabled="isLoading"
          @click="deleteItem"
        >
          {{ $i18n.t('vaults.nav.buttons.delete') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin'
export default {
  components: {
    DialogContent
  },
  mixins: [vaultIdMixin],
  computed: {
    ...mapState({
      isLoading: state => state.vaults.loading,
      selectedVaultItems: state => state.vaults.selectedVaultItems,
      files: state => state.vaults.vault.items
    }),
    fileNames() {
      return this.selectedVaultItems.map((item) => '"' + item.attributes.name + '"')
        .toString().replaceAll('","', '", "')
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      deleteSelectedVaultItems: 'vaults/deleteSelectedVaultItems'
    }),
    deleteItem() {
      const { boxId } = this.$route.params
      const { vaultId } = this

      this.deleteSelectedVaultItems({ boxId, vaultId })
    }
  }
}
</script>

<style lang="scss" scoped>
.dialog-description {
  font-weight: normal;
  font-size: 24px;
  line-height: 29px;
  text-align: center;
  color: $color-text;
}
</style>
