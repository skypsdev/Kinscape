<template>
  <v-card-title
    :class="itemIsBox && 'vault-card__title--box'"
    class="vault-card__title"
  >
    <input
      v-if="editMode && canRename"
      @click.stop
      type="text"
      v-model="name"
      :disabled="loading"
      @blur="updateName"
      @keyup.enter="updateName"
    />
    <span
      v-else
      :class="itemIsBox && 'vault-title--box'"
      v-text="truncate(name)"
      :title="name"
    />
  </v-card-title>
</template>

<script>
import { mapActions, mapGetters, mapMutations, mapState } from 'vuex'
import _ from 'lodash'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'
import filters from '@/utils/filters'
import { splitExtension } from '@/utils/common'

export default {
  name: "VaultItemTitle",
  mixins: [vaultPermissions, vaultIdMixin],
  props: {
    item: {
      type: Object, default: null,
      required: true
    }
  },
  data() {
    return {
      nameCopy: ''
    }
  },
  computed: {
    ...mapGetters({
      isSelected: 'vaults/isSelected',
      hasMorePages: 'vaults/hasMorePages'
    }),
    ...mapState('vaults', ['loading', 'vault']),
    canRename() {
      return this.canAddBoxesToVault(this.vault)
    },
    editMode() {
      return Boolean(this.isSelected(this.item.id, this.item.attributes.itemType))
    },
    extension() {
      return this.itemIsBox === false && splitExtension(this.item?.attributes?.name)[1]
    },
    itemIsBox() {
      return this.isBox(this.item)
    },
    name: {
      get() {
        if (this.item) {
          let { name } = this.item.attributes
          // should return full name if it's box or is not in edit mode
          if (this.itemIsBox || !this.editMode) return name

          // pop extension in edit mode
          return splitExtension(name)[0]
        } else return ''

      },
      set: _.debounce(function (value) {
        // prevent updating if no difference
        if (this.nameCopy.trim() == value.trim()) return


        if (!this.itemIsBox) value = `${value}.${this.extension}`

        const { id } = this.item
        const { itemType } = this.item.attributes
        this.UPDATE_VAULT_ITEM({ id, itemType, value, key: 'name' })
      }, 300)
    }
  },
  watch: {
    //usage:
    //compare for changes to decide about update
    editMode(bool) {
      if (bool) {
        this.nameCopy = this.name
      } else {
        this.nameCopy = ''
      }
    }
  },
  methods: {
    ...mapMutations('vaults', ['UPDATE_VAULT_ITEM']),
    ...mapActions('vaults', ['updateAttachment', 'updateBox']),
    truncate: t => filters.truncate(t, 27),
    async updateName() {
      try {
        // prevent updating if no difference
        if (this.nameCopy.trim() == this.name.trim() || this.loading) return

        const { id: boxId } = this.item
        let { vaultId, name } = this;

        if (this.itemIsBox) {
          await this.updateBox({ vaultId, boxId, payload: { name } })
        } else {
          await this.updateAttachment({ vaultId, boxId, payload: { title: name } })
        }

        this.nameCopy = name
      } catch (err) {
        console.error(err)
      }
    }
  }
}
</script>

<style lang="scss" src="./VaultItemTitle.scss" scoped>
</style>