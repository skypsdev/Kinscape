<template>
  <v-card-title
    :class="isBox && 'vault-card__title--box' "
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
    >
    <span
      v-else
      :class="isBox && 'vault-title--box' "
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
      return this.canAddBoxesToVault()
    },
    editMode() {
      return Boolean(this.isSelected(this.item.id, this.item.attributes.itemType))
    },
    extension() {
      return this.isBox === false && this.item?.attributes?.name?.split('.').pop()
    },
    isBox() {
      return this.item?.attributes?.itemType === 'box'
    },
    insideMyVaultView() {
      return ["MyVault", "MyBoxVault"].includes(this.$route.name)
    },
    name: {
      get() {
        if (this.item) {
          let { name } = this.item.attributes
          // should return full name if it's box or is not in edit mode
          if (this.isBox || !this.editMode) return name

          // pop extension in edit mode
          name = this.item.attributes.name.split('.')
          name.pop()
          return name.join('.')
        } else return ''

      },
      set: _.debounce(function (value) {
        // prevent updating if no difference
        if (this.nameCopy.trim() == value.trim()) return


        if (!this.isBox) value = `${value}.${this.extension}`

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

        if (!this.isBox) name = `${name}.${this.extension}`

        if (this.isBox) {
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

<style lang="scss">
.vault-card__title {
  height: 36px;
  padding: 0;
  display: flex;
  align-items: center;
  justify-content: center;

  &--box {
    height: 42px;
  }

  span {
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 14px;
    line-height: 17px;

    text-align: center;

    color: $color-text;
    &:not(.vault-title--box) {
      //truncate
      width: 100px;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
    &.vault-title--box {
      font-family: Lato;
      font-style: normal;
      font-weight: 500;
      font-size: 14px;
      line-height: 120%;
      padding: 5px 9px;

      color: $tertiary;
    }
  }

  input {
    max-width: 113px;
    background: #ffffff;
    border: 1px solid $color-medium-grey;
    box-sizing: border-box;
    height: 24px;
    border-radius: 5px;
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 13px;
    line-height: 16px;
    color: #666666;
    outline: none;
    padding: 0 9px;
    &:focus {
      border-color: darken($color-medium-grey, 5%);
    }
  }
}
</style>