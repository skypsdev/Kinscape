<template>
  <v-row>
    <template v-if="!isEditMode">
      <v-col></v-col>
      <v-col>
        <MyLifeMenu :has-simulated-path="hasSimulatedPath" />
      </v-col>
      <v-col class="d-flex flex-row align-center">
        <v-spacer />
        <AddBoxButton
          :vault-id="vaultId"
          class="mr-2"
        />
        <UploadFile class="ml-2" />
      </v-col>
    </template>
    <template v-else>
      <v-col class="d-inline-flex align-center py-0">
        <v-spacer />
        <CancelButton class="mr-2" />
        <VaultItemDetails />
        <DeleteButton class="mx-2" />
        <MoveButton class="mx-2" />
        <CopyButton class="mx-2" />
        <DownloadButton class="ml-2" />
      </v-col>
    </template>
  </v-row>
</template>

<script>
import { mapState } from 'vuex'

import MyLifeMenu from './MyLife/MyLifeMenu'
import UploadFile from './Vault/UploadFile'
import AddBoxButton from './Vault/AddBoxButton'
import DownloadButton from './Vault/DownloadButton'
import CancelButton from './Vault/CancelButton'
import MoveButton from './Vault/MoveButton'
import DeleteButton from './Vault/DeleteButton'
import CopyButton from './Vault/CopyButton'
import VaultItemDetails from '@/components/Vault/VaultItemDetails';

export default {
  components: {
    MyLifeMenu,
    UploadFile,
    AddBoxButton,
    DownloadButton,
    CancelButton,
    MoveButton,
    DeleteButton,
    CopyButton,
    VaultItemDetails
  },
  props: {
    hasSimulatedPath: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      selectedVaultItems: state => state.vaults.selectedVaultItems,
      vaultId: state => state.core.user.vault.id
    }),
    isEditMode() {
      return this.selectedVaultItems?.length
    }
  }
}
</script>
