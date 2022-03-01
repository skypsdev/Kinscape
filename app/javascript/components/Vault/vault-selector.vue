<template>
  <div class="vault-dropdown header-nav-dropdown dropdown">
    <dropdown
      :data="allVaults"
      :cb-changed="selectVault"
      :fix-list-width="false"
      class="vaultSelection"
    />
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
export default {
  props: {
    vault: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      allVaults: []
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    ...mapGetters({
      currentUserVaults: 'vaults/currentUserVaults',
      userVaultsLoaded: 'vaults/userVaultsLoaded'
    })
  },
  watch: {
    userVaultsLoaded: function (newValue, oldValue) {
      if (newValue !== oldValue && newValue === true) {
        this.allUserVaults()
      }
    }
  },
  mounted() {
    this.allUserVaults()
  },
  methods: {
    selectVault(selected) {
      window.location.href = `/vaults/${selected[0].value}`
    },
    allUserVaults() {
      this.allVaults = this.currentUserVaults.map((vault) => {
        const selected = this.vault.id === vault.id.toString()
        return {
          label: vault.attributes.name,
          value: vault.id,
          selected: selected
        }
      })
    }
  }
}
</script>

<style lang="scss">
.vaultSelection {
  margin-bottom: 0;

  .selected {
    font-size: 16px !important;
    line-height: 32px !important;
    border: none !important;
    color: #8c98a8;
    padding: 0;
    padding-right: 15px;
  }

  .inner {
    margin-left: 0;
    top: 100%;
    left: 0;
    z-index: 200;
    opacity: 1;
    visibility: visible;
    margin-top: 0.5em;
    position: absolute;
    width: 220px;
    border-radius: 3px;
    box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.2), 0 3px 60px 0 rgba(0, 0, 0, 0.2);
    padding: 0 !important;
    overflow-y: hidden !important;
    max-height: unset !important;
    font-size: 16px !important;
    background: #fff;

    .item {
      overflow-wrap: break-word;
      white-space: normal;
      border-bottom: 1px solid rgba(188, 198, 211, 0.5);
      height: auto;

      div {
        padding: 0.8em 1em;
        color: #8c98a8;
        display: block;
        font-weight: 300;
        margin: 0;
        position: relative;
      }

      &.selected {
        display: none;
      }
    }
  }
}
</style>
