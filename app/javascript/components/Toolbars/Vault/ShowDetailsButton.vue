<template>
  <div
    v-if="selectedVaultItems.length === 1"
    class="show-details-button"
  >
    <svg
      width="30"
      height="30"
      viewBox="0 0 30 30"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <path
        fill-rule="evenodd"
        clip-rule="evenodd"
        d="M0 15C0 23.2843 6.71573 30 15 30C23.2843 30 30 23.2843 30 15C30 6.71573 23.2843 0 15 0C6.71573 0 0 6.71573 0 15ZM27 15C27 21.6274 21.6274 27 15 27C8.37258 27 3 21.6274 3 15C3 8.37258 8.37258 3 15 3C21.6274 3 27 8.37258 27 15ZM16.5 12V24H13.5V12H16.5ZM16.5 9V6H13.5V9H16.5Z"
        fill="#E75739"
      />
    </svg>
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
      clearSelectedAttachments: 'vaults/clearSelectedAttachments'
    }),
    showDetails() {
      this.active = !this.active
    },
  }
}
</script>

<style lang="scss" scoped>
.show-details-button {
  height: 56px;
  width: 48px;
  display: flex;
  justify-content: center;
  align-items: center;
  cursor: pointer;
}
</style>
