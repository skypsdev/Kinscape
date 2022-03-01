<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
      class="mb-12"
      height="320"
      contain
      :src="require('../../assets/images/vault-empty.svg')"
    />
    <h4
      class="empty-state__heading f--tertiary text-center mx-auto mb-5"
      v-text="$i18n.t('vaults.empty.heading')"
    />
    <p
      class="empty-state__p f--tertiary text-center mx-auto mb-5"
      v-text="$i18n.t('vaults.empty.description')"
    />
    <div class="d-flex flex-wrap justify-center mt-8">
      <UploadFile>
        <v-btn
          large
          rounded
          color="primary"
          elevation="0"
          min-width="170"
          class="ma-2"
        >
          {{ $i18n.t('vaults.empty.upload_content') }}
        </v-btn>
      </UploadFile>
      <v-btn
        large
        rounded
        color="primary"
        elevation="0"
        min-width="170"
        class="ma-2"
        @click="addVaultBox"
      >
        {{ $i18n.t('vaults.empty.add_box') }}
      </v-btn>
    </div>
  </v-container>
</template>
<script>
import { mapActions } from 'vuex'

import vaultIdMixin from '@/components/Vault/mixins/vaultIdMixin.js'

import UploadFile from '../Toolbars/Vault/UploadFile'

export default {
  components: {
    UploadFile
  },
  mixins: [vaultIdMixin],
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
    }),
    addVaultBox() {
      this.setDialog({
        component: 'VaultAddBoxDialog',
        title: this.$i18n.t('vaults.nav.buttons.add_box'),
        data: {
          vaultId: this.vaultId,
          parentBoxId: this.$route.params?.boxId || null
        }
      })
    }
  }
}
</script>
<style lang="scss" scoped>
.empty-state {
  &__heading {
    font-weight: bold;
    font-size: 32px;
    line-height: 43px;
  }
  &__p {
    max-width: 692px;
    font-family: Enriqueta;
    font-size: 22px;
    line-height: 34px;
  }
}
</style>
