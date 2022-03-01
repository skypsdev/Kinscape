<template>
  <v-card
    elevation="0"
    :class="{
      'vault-card--selected': isSelected(item.id, item.attributes.itemType)
      }"
    class="vault-card mx-auto"
    @click.prevent="onClick"
  >
    <div
      v-if="matchValues(item,'contentType',[/video/])"
      class="vault-card__video"
      :class="isSelected(item.id, item.attributes.itemType) && 'vault-card__video--selected'"
    >
      <video playsinline>
        <source :src="item.attributes.url" />
      </video>
    </div>

    <v-img
      v-else-if="matchValues(item,'contentType',[/audio/])"
      :src="require('@/assets/images/vault/audio.svg')"
      height="85"
      :contain="matchValues(item,'contentType',[/audio/])"
      class="vault-card__image vault-card__image--box"
    ></v-img>

    <v-img
      v-else-if="matchValues(item,'itemType',[/box/])"
      :src="require('@/assets/images/vault/box.svg')"
      height="81"
      class="vault-card__image vault-card__image--box"
    ></v-img>

    <v-img
      v-else
      :src="item.attributes.coverUrl || require('@/assets/images/vault/document.svg')"
      height="85"
      class="vault-card__image"
      :contain="!matchValues(item,'contentType',[/jpeg/,/png/,/gif/])"
      :class="!matchValues(item,'contentType',[/jpeg/,/png/,/gif/]) && 'vault-card__image--box'"
    ></v-img>

    <VaultItemTitle :item="item" />
  </v-card>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

import VaultItemTitle from '@/components/Vault/VaultItemTitle';
export default {
  components: {
    VaultItemTitle
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
    })
  },
  methods: {
    ...mapActions({
      getVault: 'vaults/getVault',
      toggleVaultItemSelection: 'vaults/toggleVaultItemSelection',
      setDialog: 'layout/setDialog',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments'
    }),
    matchValues(item, key, matchArray) {
      return matchArray.some(match => item.attributes?.[key]?.match(match))
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
        await this.getVault({ vaultId: this.vaultId })
      } catch (e) {
        console.error(e)
      }
    },
  },
};
</script>

<style lang="scss" scoped>
$block: ".vault-card";
$selected-bg: rgba(252, 208, 196, 0.5);
$selected-image-bg: rgba(252, 208, 196, 0.4);
$meta-bg: rgba(75, 75, 75, 0.8);
%before {
  @include pseudo();
  background: linear-gradient(0deg, $selected-image-bg, $selected-image-bg);
}

.vault-card {
  border: 2px solid $color-medium-grey;
  box-sizing: border-box;
  border-radius: 5px !important;
  height: 127px;
  width: 127px;
  flex-direction: column;
  display: flex;
  overflow: hidden;
  @include transition();

  &:hover:not(.vault-card--selected) {
    border: 2px solid $color-primary;
    &:after {
      @include pseudo($height: 18px, $width: 18px);
      top: 8px;
      right: 8px;

      background: $primary-white;
      border: 2px solid $color-primary;
      border-radius: 50%;
      line-height: 15px;
      padding-left: 4px;
    }
  }

  &--selected {
    border: 2px solid $color-primary;
  }

  &--selected &__image,
  &--selected &__video {
    &:before {
      @extend %before;
    }
    &:after {
      @include pseudo(
        $content: url("../../assets/images/vault/check.svg"),
        $height: 18px,
        $width: 18px
      );
      top: 8px;
      right: 8px;

      border-radius: 50%;
      line-height: 15px;
      padding-left: 4px;

      background: $color-primary;
    }
  }

  &__video {
    flex: 1;
    max-height: 87px;
    position: relative;

    &:not(.vault-card__video--selected):after {
      @include pseudo(
        $content: url("../../assets/images/vault/triangle.svg"),
        $height: 48px,
        $width: 48px
      );
      @include center-absolute;
      padding-top: 13px;
      padding-left: 18px;

      border-radius: 50%;

      background: $color-primary;
    }

    video {
      height: 100%;
      object-fit: cover;
      pointer-events: none;
    }
  }
  &__image {
    position: relative;
    background: $color-dark-white;
    border-radius: 0 !important;
  }

  &__label {
    position: absolute;
    left: 0;
    top: 21px;
    z-index: 10;
    padding: 4px 12px;
    background: $color-primary;
    border-radius: 2px 10.5px 10.5px 2px;
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 16px;
    line-height: 21px;
    color: #ffffff;
  }
  &__chips {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 10;
    padding: 8px;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-end;
  }
  &__meta {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: $meta-bg;
    color: white;
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 13px;
    line-height: 16px;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    padding-top: 46px;
  }
}
</style>

<style lang="scss">
.vault-card__image--box {
  .v-image__image {
    height: 40px;
    width: 40px;
    @include center-absolute;
  }
}
</style>