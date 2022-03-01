<template>
  <div class="cancel-selection">
    <span>{{ $i18n.t('vaults.nav.buttons.selected', {count: selectedVaultItems.length}) }}</span>
    <v-icon
      large
      color="tertiary"
      @click="onCancelClick"
    >
      mdi-close
    </v-icon>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'

export default {
  computed: {
    ...mapState({
      selectedVaultItems: state => state.vaults.selectedVaultItems
    })
  },
  methods: {
    ...mapActions({
      setViewVaultMode: 'vaults/setViewVaultMode',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments',
    }),
    onCancelClick() {
      this.setViewVaultMode()
      this.clearSelectedAttachments()
    },
  }
}
</script>

<style lang="scss" scoped>
.cancel-selection {
  font-size: 18px;
  line-height: 26px;
  color: $color-tertiary;
}
</style>
