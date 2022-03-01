<template>
  <div
    class="vault-breadcrumbs d-flex"
    ref="breadcrumb"
  >
    <router-link
      :to="vaultLink"
      class="vault-breadcrumbs__item align-center d-flex"
    >
      {{ vaultName }}
    </router-link>

    <component
      v-for="(link, index) in breadcrumbComputed"
      :key="link.id"
      :is="getComponent(index)"
      :to="generateBoxLink(link.id)"
      class="vault-breadcrumbs__item align-center d-flex"
      :class="link.name=='...'&& 'vault-breadcrumbs__item--dots'"
    >
      {{link.name}}
    </component>
  </div>
</template>

<script>
import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'
const takeRight = (arr, n = 1) => arr.slice(arr.length - n, arr.length)

/**
 * HOW BREADCRUMB WORK
 * 
 * There are 2 obligations: 
 *  - breadcrumbs should show not more than 5 crumbs, otherwise in a middle of breadcrumb show three dots `...`
 *  - if the distance between breadcrumb and sorting is less, then 150px in a middle of breadcrumb show three dots `...` and pop item from middle of breadcrumb
 * 
 * IMPLEMENTATION
 * 1. it use `takeCount = 3` as an initial takeRight param
 * 2. if fullBreadcrumb.length > 4 then use takeRight() to leave only specified quantity of breadcrumbs from right
 * 3. every time when component is loaded, it use calculateTakeCounter() to check 2nd obligation(from above section)
 * 4. the function recursively check if it has allowed distance, if not it'll pop takeCount
 */
export default {
  name: "VaultBreadcrumbs",
  mixins: [vaultIdMixin],
  props: {
    vault: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      takeCount: 3
    }
  },
  computed: {
    vaultLink() {
      return {
        name: this.insideMyVaultView ? 'MyVault' : 'communityVault', params: {
          id: this.community.id
        }
      }
    },
    vaultName() {
      return this.insideMyVaultView ? this.$i18n.t('vault.my_vault') : `${this.community.name} ${this.$i18n.t('vaults.breadcrumb.vault')}`
    },
    fullBreadcrumb() {
      let breadcrumb = [...this.vault?.attributes?.parent_boxes || [],]

      if (this.vault?.attributes?.item_type == 'box') {
        breadcrumb.push({ id: this.vault.id, name: this.vault?.attributes?.name })
      }

      return breadcrumb;
    },
    breadcrumbComputed() {
      const { fullBreadcrumb, takeCount } = this;
      if (fullBreadcrumb.length > 4) {
        return [fullBreadcrumb[0], { id: null, name: '...' }, ...takeRight(fullBreadcrumb, takeCount)]
      } else {
        return fullBreadcrumb
      }
    },
  },
  async mounted() {
    await this.$nextTick()
    this.calculateTakeCounter()
  },
  methods: {
    generateBoxLink(boxId) {
      return {
        name: this.insideMyVaultView ? 'MyBoxVault' : 'CommunityBoxVault', params: {
          boxId,
          id: this.vaultId
        }
      }
    },
    getComponent(index) {
      return index !== this.breadcrumbComputed.length - 1 ? 'router-link' : 'div'
    },
    enoughBreadcrumbWidth() {
      const { right } = this.$refs['breadcrumb'].getBoundingClientRect()
      const { left } = document.getElementById('vault-sorting').getBoundingClientRect()

      return left - right > 150
    },
    async calculateTakeCounter() {
      if (!this.enoughBreadcrumbWidth() && this.takeCount >= 1) {
        this.takeCount = this.takeCount - 1

        await this.$nextTick()
        this.calculateTakeCounter()
      }
    },
  },
}
</script>

<style lang="scss" >
.vault-breadcrumbs {
  padding: 0;

  &__item {
    text-decoration: none;
    position: relative;
    font-family: Enriqueta;
    font-style: normal;
    font-weight: 500;
    font-size: 14px;
    line-height: 19px;
    &,
    &:visited {
      color: $tertiary !important;
    }
    &:not(:last-child) {
      padding-right: 25px;
      &:after {
        @include pseudo($width: 7px, $height: 12px);
        @include center-absolute-y;
        right: 9.5px;
        background-image: url("../../assets/images/vault/arrow_dark.svg");
      }

      &:hover {
        color: #8b78fe !important;
      }

      cursor: pointer;
    }
    &--dots,
    &:last-child {
      cursor: initial !important;
    }

    &:first-child,
    &:last-child {
      font-weight: bold;
    }
    &:last-child {
      color: $primary !important;
    }
  }
}
</style>
