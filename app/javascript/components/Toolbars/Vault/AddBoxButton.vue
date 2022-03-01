<template>
  <v-btn
    rounded
    outlined
    color="primary"
    elevation="0"
    min-width="114"
    :disabled="vaults.loading || disabled"
    @click="addVaultBox"
  >
    <v-icon left>mdi-plus-circle-outline</v-icon>
    {{ $i18n.t('vaults.nav.buttons.add_box') }}
  </v-btn>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
export default {
  mixins: [vaultPermissions],
  props: {
    vaultId: {
      default: null,
      validator: prop => typeof prop === 'number' || prop === null,
      required: true
    }
  },
  computed: {
    ...mapState(['vaults']),
    disabled() {
      return this.canAddBoxesToVault() == false
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    addVaultBox() {
      this.setDialog({
        component: 'VaultAddBoxDialog',
        title: this.$i18n.t('vaults.nav.buttons.add_box'),
        data: {
          vaultId: this.vaultId,
          parentBoxId: this.$route.params?.boxId || null
        }
      })
    }
  }
}
</script>
