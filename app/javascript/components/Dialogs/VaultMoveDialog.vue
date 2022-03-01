<template>
  <DialogContent>
    <template #close-btn="{handleClose}">
      <v-btn
        icon
        min-height="50"
        min-width="50"
        @click="handleClose"
      >
        <v-img
          max-width="25.67"
          :src="require('@/assets/images/vault/clear.svg')"
          class="move-dialog__close"
        />
      </v-btn>
    </template>

    <template v-slot:content>
      <div class="move-dialog__content mx-auto">
        <div class="move-dialog__header">
          <h3> {{ $i18n.t('vaults.move_files_to_box_modal.title_one') }}</h3>
          <h4> {{ $i18n.t('vaults.move_files_to_box_modal.sub_title') }}</h4>
        </div>
        <div class="move-dialog__items">
          <div
            class="copy-items__header"
            v-if="activeBox"
          >
            <button @click="backToParentBox">
              <v-img
                max-width="16"
                :src="require('@/assets/images/vault/arrow_back.svg')"
              />
            </button>
            <span>{{activeBox.attributes.name}}</span>
          </div>
          <VaultMoveDialogBoxesList :open-box="openBox" />
        </div>
      </div>
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          x-large
          width="160"
          rounded
          color="primary"
          elevation="0"
          class="ma-1 move-dialog__move-btn"
          :disabled="isLoading"
          @click="moveToSelectedBox"
        >
          {{ $i18n.t('vaults.move_files_to_box_modal.move') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import VaultMoveDialogBoxesList from '@/components/Dialogs/VaultMoveDialogBoxesList'
export default {
  components: {
    DialogContent,
    VaultMoveDialogBoxesList
  },
  mixins: [vaultIdMixin],
  data() {
    return {
      isLoading: false
    }
  },
  computed: {
    ...mapState({
      vault: state => state.vaults.vault,
      boxes: state => state.vaults.boxes.items,
      activeBox: state => state.vaults.boxes.activeBox
    }),
    ...mapGetters({
      selectedIds: 'vaults/selectedIds'
    }),
    parentBoxId() {
      if (!this.activeBox?.attributes?.parentBoxes?.length) return null

      const { length } = this.activeBox?.attributes.parentBoxes

      return this.activeBox?.attributes.parentBoxes[length - 1].id
    }
  },
  created() {
    const { boxId } = this.$route.params

    if (boxId) {
      this.loadInfo(boxId)
    }

    this.loadItems(boxId)
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setViewVaultMode: 'vaults/setViewVaultMode',
      getVault: 'vaults/getVault',
      getBox: 'vaults/getBox',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments',
      clearVault: 'vaults/clearVault',
      getActionDialogBoxItems: 'vaults/getActionDialogBoxItems',
      getActionDialogBoxInfo: 'vaults/getActionDialogBoxInfo',
      moveAttachments: 'vaults/moveAttachments'
    }),
    ...mapMutations('vaults', ['SET_ACTION_DIALOG_BOX_INFO']),
    loadItems(boxId) {
      this.getActionDialogBoxItems({ vaultId: this.vaultId, boxId })
    },
    loadInfo(boxId) {
      this.getActionDialogBoxInfo({ vaultId: this.vaultId, boxId })
    },
    async moveToSelectedBox() {
      try {
        this.isLoading = true

        const model = {
          vaultId: this.vaultId,
          boxId: this?.activeBox?.id || null,
          ids: this.selectedIds.filesIds
        }

        await this.moveAttachments(model)

        this.setSnackbar(this.$i18n.t('vaults.messages.moved'))

        this.clearSelectedAttachments()
        this.closeDialog()

        this.clearVault()
      } finally {
        this.isLoading = false
      }
    },
    backToParentBox() {
      if (this.parentBoxId) {
        this.loadInfo(this.parentBoxId)
      } else {
        // reset active box
        this['SET_ACTION_DIALOG_BOX_INFO'](null)
      }
      this.loadItems(this.parentBoxId)
    },
    openBox(box) {
      this.loadInfo(box.id)
      this.loadItems(box.id)
    },
  }
}
</script>

<style lang="scss">
.v-dialog {
  width: 100%;
  .dialog-title {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: bold;
    font-size: 34px;
    line-height: 1;

    color: $color-tertiary;
  }
  .dialog-header {
    padding: 25.18px 37.17px 15.82px 24.98px;
  }
}
</style>