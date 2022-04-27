<template>
  <v-card
    elevation="0"
    class="vault-card mx-auto"
    :class="isSelected && 'vault-card--selected'"
  >
    <div
      v-if="type == 'video'"
      class="vault-card__video"
      :class="isSelected && 'vault-card__video--selected'"
    >
      <video playsinline>
        <source :src="url" />
      </video>
    </div>

    <v-img
      v-else-if="type == 'audio'"
      :src="require('@/assets/images/vault/audio.svg')"
      height="85"
      contain
      class="vault-card__image vault-card__image--box"
    ></v-img>

    <v-img
      v-else-if="type == 'box'"
      :src="require('@/assets/images/vault/box.svg')"
      height="81"
      class="vault-card__image vault-card__image--box"
    ></v-img>

    <v-img
      v-else
      :src="url || require('@/assets/images/vault/document.svg')"
      height="85"
      class="vault-card__image"
      :contain="isOtherType"
      :class="isOtherType && 'vault-card__image--box'"
    ></v-img>

    <slot></slot>
  </v-card>
</template>

<script>
export default {
  name: "VaultItemCard",
  props: {
    type: {
      type: String,
      default: '',
      required: true
    },
    url: {
      type: String,
      default: '',
      required: true
    },
    isSelected: {
      type: Boolean,
      default: false,
      required: true
    }
  },
  computed: {
    isOtherType() {
      return this.type == 'other'
    }
  }
}
</script>
<style lang="scss" src="./VaultItem.scss" scoped>
</style>

<style lang="scss" >
.vault-card__image--box .v-image__image {
  height: 40px;
  width: 40px;
  @include center-absolute;
}
</style>
