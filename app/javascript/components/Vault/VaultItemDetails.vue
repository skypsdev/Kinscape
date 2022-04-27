<template>
  <v-tooltip
    content-class="details-tooltip"
    bottom
  >
    <template v-slot:activator="{ on, attrs }">
      <span
        v-bind="attrs"
        v-on="on"
      >
        <ShowDetailsButton></ShowDetailsButton>
      </span>
    </template>
    <div class="details">
      <h3 class="details-title d-inline-flex">
        <v-img
          max-width="26"
          height="26"
          :src="require('@/assets/images/vault/error.svg')"
          alt="info icon"
          class="float-left"
        /> {{$i18n.t('vaults.tooltip.title')}}
      </h3>
      <div class="details-content d-flex">
        <div class="details-description">
          <p>{{$$(selectedVaultItems[0],'attributes','name')}}</p>
          <h4>{{$i18n.t('vaults.tooltip.created_by')}}: <span>{{$$(selectedVaultItems[0],'attributes','userName') || '-'}}</span></h4>
          <h4>{{$i18n.t('vaults.tooltip.size')}}: <span>{{$$(selectedVaultItems[0],'attributes','size') || '-'}}</span></h4>
          <h4>{{$i18n.t('vaults.tooltip.date_created')}}: <span>{{formatDate($$(selectedVaultItems[0],'attributes','createdAt')) || '-'}}</span>
          </h4>
        </div>
        <div class="details-aside">
          <div
            class="details-preview"
            v-if="checkContentType('image', $$(selectedVaultItems[0],'attributes','contentType'))"
          >
            <v-img
              max-width="40"
              height="40"
              :src="$$(selectedVaultItems[0],'attributes','url')"
              :alt="`preview image: ${$$(selectedVaultItems[0],'attributes','name')}`"
              class="ml-auto"
            />
          </div>
          <div
            class="details-permissions"
            v-if="visiblePermissionNote"
          >
            <v-img
              max-width="18"
              height="18"
              :src="require('@/assets/images/vault/error2.svg')"
              alt="info icon"
              class="float-left"
            /> <span>{{$i18n.t('vaults.tooltip.denied')}}</span>
          </div>
        </div>
      </div>
    </div>
  </v-tooltip>
</template>

<script>
import { mapState } from 'vuex'

import vaultPermissions from '@/components/Vault/mixins/vaultPermissionsMixin.js'

import ShowDetailsButton from '@/components/Toolbars/Vault/ShowDetailsButton'
import { checkContentType } from '@/components/Dialogs/PreviewMediaFileDialog';
export default {
  name: "VaultItemDetails",
  components: { ShowDetailsButton },
  mixins: [vaultPermissions],
  data() {
    return {
      show: true
    }
  },
  computed: {
    ...mapState('vaults', ['selectedVaultItems']),
    visiblePermissionNote() {
      return this.selectedVaultItems.every(item => this.isAsset(item) && !this.canManageAsset(item))
    }
  },
  methods: {
    checkContentType,
    formatDate(createdAt) {
      return this.$moment(createdAt).format('Do MMMM YYYY')
    }
  }
}
</script>

<style scoped lang="scss">
$shadow: rgba(0, 0, 0, 0.16);

.details {
  position: relative;
  opacity: 1;
  padding: 15px 24px 25px 36px !important;
  width: 512px;
  border-radius: 5px;
  background: $color-secondary-lightest;
  padding: 0;
  filter: drop-shadow(0px 10px 20px $shadow);

  &::before {
    @include pseudo($width: 0, $height: 0);
    top: -22px;
    left: 48%;

    border-style: solid;
    border-width: 0 11px 22px 11px;
    border-color: transparent transparent $color-secondary-lightest transparent;
  }

  &-tooltip {
    z-index: 8;
    padding: 0;
    background: unset;
    opacity: 1;
    padding-top: 20px;
  }

  &-title {
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 23px;
    text-align: justify;
    color: $color-tertiary;

    .v-image {
      margin-right: 11px;
    }
  }
  &-description {
    h4 {
      font-family: Enriqueta;
      font-style: normal;
      font-weight: bold;
      font-size: 16px;
      line-height: 21px;
      letter-spacing: -0.02em;
      color: $color-tertiary;

      span {
        font-weight: normal;
        font-family: Lato;
        font-style: normal;
        font-weight: normal;
        font-size: 16px;
        line-height: 19px;
        color: $color-tertiary;
      }
    }

    p {
      font-family: Lato;
      font-style: normal;
      font-weight: normal;
      font-size: 13px;
      line-height: 16px;
      margin: 0;
      color: $color-text;
    }
  }
  &-aside {
    padding-left: 32px;
  }

  &-preview {
    padding-right: 30px;
    margin-bottom: 20px;
    border-radius: 5px;
    .v-image {
      border-radius: 5px;
    }
  }

  &-aside {
    display: flex;
    flex-direction: column;
    justify-content: flex-end;
  }
  &-permissions {
    display: flex;
    max-width: 164px;
    background: $color-disabled;
    border: 1px solid $color-grey;
    box-sizing: border-box;
    border-radius: 10px;
    padding: 8px 10px 10px 8px;

    font-family: Lato;
    font-style: normal;
    font-weight: 600;
    font-size: 13px;
    line-height: 16px;

    color: $color-text;

    .v-image {
      margin-right: 13px;
    }
  }
}
</style>
