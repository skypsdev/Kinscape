<template>
  <v-tooltip
    content-class="details-btn__tooltip"
    bottom
    :disabled="!isDisabled"
  >
    <div class="details-btn"> {{ $i18n.t('vaults.nav.buttons.no_delete_permissions') }}</div>
    <template v-slot:activator="{ on, attrs }">
      <span
        v-bind="attrs"
        v-on="on"
      >
        <v-btn
          rounded
          outlined
          color="primary"
          elevation="0"
          min-width="160"
          :disabled="isDisabled"
          @click="onDeleteClick"
        >
          <v-icon left>mdi-delete-outline</v-icon>
          {{ $i18n.t('vaults.nav.buttons.delete') }}
        </v-btn>
      </span>
    </template>
  </v-tooltip>

</template>

<script>
import { mapActions } from 'vuex'

import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
export default {
  name: 'DeleteButton',
  mixins: [vaultPermissions],
  computed: {
    isDisabled() {
      return this.selectedVaultItems.every(this.canManage) === false
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    onDeleteClick() {
      this.setDialog({
        component: 'VaultDeleteDialog',
        title: this.$i18n.t('vaults.attachments.delete.title')
      })
    }
  }
}
</script>
