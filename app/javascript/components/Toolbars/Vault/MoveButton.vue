<template>
  <v-tooltip
    content-class="details-btn__tooltip"
    bottom
    :disabled="!isDisabled"
  >
    <div class="details-btn"> {{ $i18n.t('vaults.nav.buttons.no_move_permissions') }}</div>
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
          @click="onMoveClick"
        >
          <v-icon left>mdi-share-outline</v-icon>
          {{ $i18n.t('vaults.nav.buttons.move') }}
        </v-btn>
      </span>
    </template>
  </v-tooltip>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
export default {
  name: 'MoveButton',
  mixins: [vaultPermissions, vaultIdMixin],
  computed: {
    ...mapState("vaults", ["selectedVaultItems"]),
    ...mapState('families', ['community']),
    isDisabled() {
      return this.selectedVaultItems.every(item => this.isAsset(item) && !this.canManageAsset(item))
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    onMoveClick() {
      this.setDialog({
        component: 'VaultMoveDialog',
        size: 'big',
        title: this.$i18n.t(`vaults.move_files_to_box_modal.${this.insideBoxView ? 'within_box' : 'within_vault'}`)
      })
    }
  }
}
</script>
