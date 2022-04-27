<template>
  <VaultItemCard
    :is-selected="Boolean(isSelected(item.id, item.attributes.itemType))"
    :type="itemType"
    :url="itemUrl"
    @click.native="onClick"
  >
    <VaultItemTitle :item="item" />
  </VaultItemCard>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

import VaultItemTitle from '@/components/Vault/VaultItemTitle';
import VaultItemCard from '@/components/Vault/VaultItemCard.vue';
export default {
  components: {
    VaultItemTitle,
    VaultItemCard
  },
  mixins: [vaultIdMixin],
  props: {
    item: {
      type: Object,
      required: true
    },
  },
  data: () => ({
    counter: 0
  }),
  computed: {
    ...mapState({
      items: state => state.vaults.vault.items,
      vault: state => state.vaults.vault
    }),
    ...mapGetters({
      isSelected: 'vaults/isSelected',
      hasMorePages: 'vaults/hasMorePages'
    }),
    itemType() {
      let result

      switch (true) {
        case this.matchTypes('contentType', [/video/]):
          result = 'video'
          break

        case this.matchTypes('contentType', [/jpeg/, /png/, /gif/]):
          result = 'image'
          break

        case this.matchTypes('contentType', [/audio/]):
          result = 'audio'
          break

        default:
          result = this.item.itemType || 'other'
          break
      }

      return result
    },
    itemUrl() {
      const { url, coverUrl } = this.item.attributes
      if (this.itemType == 'image') {
        return coverUrl
      } else if (url) {
        return url
      } else return ''
    }
  },
  methods: {
    ...mapActions({
      getVaultItems: 'vaults/getVaultItems',
      toggleVaultItemSelection: 'vaults/toggleVaultItemSelection',
      setDialog: 'layout/setDialog',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments'
    }),
    matchTypes(key, matchArray) {
      return matchArray.some(match => this.item.attributes?.[key]?.match(match))
    },
    onClick() {
      this.counter++;
      if (this.counter === 1) {
        this.timer = setTimeout(() => {
          this.counter = 0;
          this.singleClick()
        }, 300);
        return;
      }
      clearTimeout(this.timer);
      this.counter = 0;
      this.doubleClick()
    },
    singleClick() {
      this.toggleVaultItemSelection(this.item)
    },
    doubleClick() {
      const { attributes, id } = this.item
      if (attributes.contentType && attributes.contentType.match(/image|audio|video/)) {
        this.setDialog({
          component: 'PreviewMediaFileDialog',
          size: 'big',
          title: attributes.name,
          data: {
            file: { ...attributes, ... this.file, id },
            itemsRef: 'state.vaults.vault.items',
            hasMoreDataRef: 'getters.vaults/hasMorePages',
            loadMoreItems: this.getMoreVaultItems

          }
        })
      } else if (attributes.itemType === 'box') {
        this.clearSelectedAttachments()
        this.$router.push({
          name: this.insideMyVaultView ? 'MyBoxVault' : 'CommunityBoxVault',
          params: { boxId: this.item.id, id: this.$route.params.id },
          query: {}
        })
      }
    },
    async getMoreVaultItems() {
      try {
        await this.getVaultItems({ vaultId: this.vaultId })
      } catch (e) {
        console.error(e)
      }
    },
  },
};
</script>




