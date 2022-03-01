<template>
  <div class="move-dialog__content mx-auto">
    <div class="move-dialog__header">
      <h3> {{ $i18n.t('vaults.copy_files_to_box_modal.select_box')}} </h3>
    </div>
    <div class="move-dialog__items">
      <div class="copy-items__header">

        <!-- back button  -->
        <template v-if="activeBox">
          <button @click="backToParentBox">
            <v-img
              max-width="16"
              :src="require('@/assets/images/vault/arrow_back.svg')"
            />
          </button>
          <span>{{activeBox.attributes.name}}</span>
        </template>

        <!-- active vault name -->
        <span v-else>{{$$(activeVault,'attributes','name')}}</span>
      </div>
      <VaultMoveDialogBoxesList :open-box="openBox">
      </VaultMoveDialogBoxesList>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'

import spinnerMixin from '@/mixins/spinnerMixin.js'
import VaultMoveDialogBoxesList from '@/components/Dialogs/VaultMoveDialogBoxesList'

export default {
  name: "VaultCopyDialogBoxes",
  components: { VaultMoveDialogBoxesList },
  mixins: [spinnerMixin],
  props: {
    activeVault: {
      type: Object,
      default: () => { },
      required: true
    }
  },
  computed: {
    ...mapState({
      boxes: state => state.vaults.boxes.items,
      activeBox: state => state.vaults.boxes.activeBox
    }),
    ...mapState('core', ['user']),
    ...mapState('families', ['community']),
    ...mapGetters({
      selectedIds: 'vaults/selectedIds'
    }),
    parentBoxId() {
      if (!this.activeBox?.attributes?.parentBoxes?.length) return null

      const { length } = this.activeBox?.attributes.parentBoxes

      return this.activeBox?.attributes.parentBoxes[length - 1].id
    },
    vaultId() {
      return this?.activeVault?.id || null
    }
  },
  created() {
    this.loadItems()
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      getActionDialogBoxItems: 'vaults/getActionDialogBoxItems',
      getActionDialogBoxInfo: 'vaults/getActionDialogBoxInfo'
    }),
    ...mapMutations('vaults', ['SET_ACTION_DIALOG_BOX_INFO']),
    async loadItems(boxId) {
      try {
        this.onLoading()

        await this.getActionDialogBoxItems({ vaultId: this.vaultId, boxId })
      } finally {
        this.onLoaded()
      }
    },
    loadInfo(boxId) {
      this.getActionDialogBoxInfo({ vaultId: this.vaultId, boxId })
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

<style>
</style>