<template>
  <ul class="copy-items__list">
    <li
      v-for="(item) in boxes"
      :key="item.ids"
      class="copy-list__item d-flex align-center"
      @click="openBox(item)"
    >
      <v-img
        max-width="40"
        :src="require('@/assets/images/vault/box.svg')"
      /> <span>{{item.attributes.name}}</span>

      <v-img
        class="ml-auto"
        max-width="26"
        :src="require('@/assets/images/vault/keyboard_arrow_right.svg')"
      />
    </li>
    <slot></slot>
  </ul>
</template>

<script>
import { mapState } from 'vuex'
export default {
  name: "VaultMoveDialogBoxesList",
  props: {
    openBox: {
      type: Function,
      default: () => null,
      required: true
    }
  },
  computed: {
    ...mapState({
      boxes: state => state.vaults.boxes.items,
    }),
  }
}
</script>

<style>
</style>