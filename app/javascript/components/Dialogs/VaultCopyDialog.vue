<template>
  <DialogContent :title="dialogTitle">
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
          class="copy-dialog__close"
        />
      </v-btn>
    </template>

    <template v-slot:content>

      <v-fade-transition mode="out-in">
        <VaultCopyDialogBoxes
          :active-vault="selectedVault"
          v-if="selectedVault"
        />
        <div
          v-else
          class="move-dialog__content copy-dialog__content mx-auto"
        >
          <div class="move-dialog__header copy-dialog__header">
            <h3> {{ $i18n.t('vaults.copy_files_to_box_modal.select') }}</h3>
            <h4> {{ $i18n.t('vaults.copy_files_to_box_modal.within_community') }} </h4>
            <FormSearch
              class="copy-dialog__search"
              :placeholder="$i18n.t('vaults.copy_files_to_box_modal.search')"
              @setSearch="$event => search = $event"
            />
          </div>
          <div class="move-dialog__items copy-dialog__items">
            <v-row no-gutters>
              <v-col
                v-for="(item,index) in vaults"
                :key="item.ids"
                cols="12"
                sm="4"
              >
                <div :class="index>2 && 'copy-item--pad-top'">
                  <div
                    class="w-100 d-flex align-center copy-item"
                    @click="selectVault(item)"
                  >
                    <div class="copy-item__preview">
                      <v-img
                        max-width="24"
                        :src="item.attributes.avatarUrl || require('@/assets/images/vault/empty_vault.svg')"
                      />
                    </div>
                    <p class="copy-item__title">{{item.attributes.name}}</p>
                  </div>
                </div>
              </v-col>
            </v-row>
          </div>
        </div>
      </v-fade-transition>

    </template>

    <template
      v-slot:actions
      v-if="selectedVault"
    >
      <div class="d-flex justify-center">
        <v-btn
          x-large
          width="160"
          rounded
          elevation="0"
          class="ma-1 move-dialog__move-btn copy-dialog__back-btn"
          :disabled="isLoading"
          @click="selectedVault = null"
        >
          <v-img
            max-width="16"
            :src="require('@/assets/images/vault/arrow_back.svg')"
          /> {{ $i18n.t('vaults.copy_files_to_box_modal.back') }}
        </v-btn>

        <v-btn
          x-large
          width="160"
          rounded
          color="primary"
          elevation="0"
          class="ma-1 move-dialog__move-btn"
          :disabled="isLoading"
          @click="copyToSelectedBox"
        >
          {{ $i18n.t('vaults.copy_files_to_box_modal.copy') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
import spinnerMixin from '@/mixins/spinnerMixin.js'

import FormSearch from "@/components/Elements/Forms/Search";
import DialogContent from '@/components/Layout/Dialog/DialogContent'
import VaultCopyDialogBoxes from '@/components/Dialogs/VaultCopyDialogBoxes'

export default {
  name: "VaultCopyDialog",
  components: {
    DialogContent,
    VaultCopyDialogBoxes,
    FormSearch
  },
  mixins: [vaultIdMixin, spinnerMixin],
  data() {
    return {
      selectedVault: null,
      search: ''
    }
  },
  computed: {
    ...mapState({
      boxes: state => state.vaults.boxes.items,
      vaults: state => state.vaults.boxes.vaults,
      activeBox: state => state.vaults.boxes.activeBox
    }),
    ...mapGetters({
      selectedIds: 'vaults/selectedIds'
    }),
    newVaultId() {
      return this?.selectedVault?.id || null
    },
    dialogTitle() {
      return this.$i18n.t(`vaults.copy_files_to_box_modal.${this.selectedVault ? 'title1' : 'title2'}`)
    }
  },
  watch: {
    search: {
      handler: "loadVaults",
      immediate: true
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      getVaultItems: 'vaults/getVaultItems',
      getBox: 'vaults/getBox',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments',
      clearVault: 'vaults/clearVault',
      copyAttachments: 'vaults/copyAttachments',
      getActionDialogBoxVaults: 'vaults/getActionDialogBoxVaults'
    }),
    selectVault(vault) {
      this.selectedVault = vault
    },
    async loadVaults(query) {
      try {
        this.onLoading()

        await this.getActionDialogBoxVaults({ query })

      } finally {
        this.onLoaded()
      }
    },
    async copyToSelectedBox() {
      try {
        this.onLoading()
        const { vaultId, newVaultId } = this

        const model = {
          newVaultId,
          vaultId,
          boxId: this?.activeBox?.id || null,
          ids: this.selectedIds.filesIds
        }

        await this.copyAttachments(model)

        this.setSnackbar(this.$i18n.t('vaults.messages.copied'))

        this.clearSelectedAttachments()
        this.closeDialog()

        this.clearVault()

        // refetch data
        const { boxId } = this.$route.params
        if (this.insideBoxView) this.getBox({ vaultId, boxId })
        else this.getVaultItems({ vaultId, params: { page: 1 } })

      } finally {
        this.onLoaded()
      }
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

.copy-dialog {
  &__items {
    background-color: $color-dark-white;
    padding: 16px 74px;
  }

  &__content {
    max-width: 920px;
  }

  &__header {
    padding: 53px 0 56px;
    position: relative;
  }
  &__back-btn {
    background: #ffffff;
    border: 1px solid $color-primary;
    color:$color-primary !important;
    .v-image {
      margin-right: 8px;
    }
    .v-image__image {
      filter: invert(50%) sepia(36%) saturate(5692%) hue-rotate(339deg)
        brightness(95%) contrast(91%);
    }
  }

  &__search {
    max-width: 300px;
    margin-top: 20px !important;
  }
}

.copy-item {
  display: flex;
  align-items: center;
  cursor: pointer;
  &:hover .copy-item__title {
    color: darken($color: $color-tertiary, $amount: 50%);
  }
  &--pad-top {
    padding-top: 24px;
  }
  &__preview {
    background: $color-light-grey;
    min-width: 50px;
    height: 50px;
    justify-content: center;
    align-items: center;
    display: flex;
    border-radius: 50%;
    margin-right: 12px;
  }
  &__title {
    margin: 0 !important;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;

    max-width: 180px;
    white-space: nowrap;
    overflow: hidden;
    text-overflow: ellipsis;
    /* identical to box height, or 133% */
  }
}

.dialog-content {
  padding: 0 89px 124px !important;
}
</style>
