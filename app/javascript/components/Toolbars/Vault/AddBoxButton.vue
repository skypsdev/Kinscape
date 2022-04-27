<template>
  <v-btn
    v-if="!isMobile"
    rounded
    outlined
    color="primary"
    elevation="0"
    min-width="114"
    :disabled="disabled"
    @click="addVaultBox"
  >
    <v-icon left>mdi-plus-circle-outline</v-icon>
    {{ $i18n.t('vaults.nav.buttons.add_box') }}
  </v-btn>
  <v-btn
    v-else
    color="primary"
    fab
    small
    rounded
    outlined
    elevation="0"
    :disabled="disabled"
    @click="addVaultBox"
  >
    <v-icon>mdi-plus</v-icon>
  </v-btn>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
import breakpointsMixin from '@/mixins/breakpointsMixin'
export default {
  mixins: [vaultPermissions, breakpointsMixin],
  props: {
    vaultId: {
      default: null,
      validator: prop => typeof prop === 'string' || prop === null,
      required: true
    }
  },
  computed: {
    ...mapState('vaults', ['loading','vault']),
    disabled() {
      return !this.canAddBoxesToVault(this.vault) || this.loading
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
