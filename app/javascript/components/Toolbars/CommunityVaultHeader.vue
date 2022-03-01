<template>
  <v-row>
    <template v-if="!isEditMode" >
      <v-col cols="4">
        <CommunityBreadcrumbs v-if="!isMobile"/>
        <BackButton v-else/>
      </v-col>
      <v-col cols="4" class="d-flex flex-row align-center justify-center fill-height">
        <CommunityTabDropdown v-if="isMobile"/>
        <CommunityMenu
          v-else
          :community-id="community.id"
          :has-simulated-path="hasSimulatedPath"
        />
      </v-col>
      <v-col class="d-flex flex-row align-center">
        <v-spacer/>
        <AddBoxButton :vault-id="community.vaultId" class="mr-2"/>
        <UploadFile :vault-id="community.vaultId" class="ml-2"/>
      </v-col>
    </template>
    <template v-else>
      <v-col class="d-inline-flex align-center py-0">
        <v-spacer/>
        <CancelButton class="mr-2"/>
        <VaultItemDetails />
        <DeleteButton class="mx-2"/>
        <MoveButton class="mx-2"/>
        <CopyButton class="mx-2"/>
        <DownloadButton class="ml-2"/>
      </v-col>
    </template>
  </v-row>
</template>

<script>
import {mapState} from 'vuex'

import UploadFile from './Vault/UploadFile'
import AddBoxButton from './Vault/AddBoxButton'
import DownloadButton from './Vault/DownloadButton'
import CancelButton from './Vault/CancelButton'
import MoveButton from './Vault/MoveButton'
import DeleteButton from './Vault/DeleteButton'
import CopyButton from './Vault/CopyButton'
import CommunityMenu from './Community/CommunityMenu'
import CommunityBreadcrumbs from './Communities/CommunityBreadcrumbs'
import CommunityTabDropdown from './Community/CommunityTabDropdown'
import BackButton from './Community/BackButton'
import breakpointsMixin from '../../mixins/breakpointsMixin'
import VaultItemDetails from '@/components/Vault/VaultItemDetails';
export default {
  components: {
    BackButton,
    CommunityTabDropdown,
    CommunityMenu,
    CommunityBreadcrumbs,
    UploadFile,
    AddBoxButton,
    DownloadButton,
    CancelButton,
    MoveButton,
    DeleteButton,
    CopyButton,
    VaultItemDetails
  },
  mixins: [
    breakpointsMixin
  ],
  props:{
    hasSimulatedPath: {
      type:Boolean,
      default:false
    }
},
  computed: {
    ...mapState({
      selectedVaultItems: state => state.vaults.selectedVaultItems,
      community: state => state.families.community
    }),
    isEditMode () {
      return this.selectedVaultItems?.length
    }
  }
}
</script>
