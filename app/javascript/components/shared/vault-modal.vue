<template>
  <div
    id="insert_from_vault_modal"
    class="modal vault-modal vault-modal-flexible-height active"
  >
    <div class="modal-container">
      <div class="modal-content">
        <div class="modal-inner-wrapper">
          <div class="vault-modal-inner">
            <a
              class="close"
              :title="$i18n.t('vaults.insert_from_vault_modal.close')"
              @click="$modal.hide(`insert-vault-modal--${parentUid}`)"
            />
            <div class="modal-header">
              <h3 class="text-light">
                {{ $i18n.t('vaults.insert_from_vault_modal.title') }}
              </h3>
            </div>

            <div class="modal-section vaults-list-section">
              <div class="flexslider slider">
                <ul
                  id="vaults-list"
                  class="blocks vaults-list slides"
                >
                  <li
                    v-for="selectableVault in selectableVaults"
                    :key="selectableVault.id"
                    class="block vault-list-item"
                    :class="{ current: isSelectedVault(selectableVault) }"
                    @click="selectVault(selectableVault)"
                  >
                    <a class="cover">
                      <span
                        class="cover-bg"
                        :style="{
                          'background-image':
                            `url(${selectableVault.attributes.cover_url})`
                        }"
                      />
                      <span class="title">
                        <span class="title-text">
                          {{ selectableVault.attributes.name }}
                        </span>
                      </span>
                    </a>
                  </li>
                </ul>
              </div>
            </div>

            <div class="modal-section vaults-list-section">
              <vault-boxes
                :boxes="boxes"
                :move-mode="true"
                :selected-box.sync="currentBox"
              />

              <vault-attachments
                v-if="currentVault"
                :vault="currentVault"
                :filtered-attachments="filteredAttachments"
                :current-box="currentBox"
                :media-files="mediaFiles"
              />

              <div v-if="!isLoading && currentVault &&
                  !selectedVaultFileIds.length &&
                  (!boxes.length || currentBox)">
                {{
                  $i18n.t('vaults.insert_from_vault_modal.empty_vault_or_box')
                }}
              </div>
            </div>
            <div class="modal-actions">
              <button @click="insertAttachments">
                {{ $i18n.t('vaults.insert_from_vault_modal.insert') }}
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

import VaultAttachments from '../Vault/VaultItem'
import VaultBoxes from '../Vault/VaultBox'

export default {
  components: { VaultAttachments, VaultBoxes },
  props: {
    currentUser: {
      type: Object,
      required: true
    },
    families: {
      type: Array,
      required: true
    },
    parentUid: {
      type: Number,
      required: true
    }
  },
  data() {
    return {
      currentBox: null,
      currentVault: null
    }
  },
  computed: {
    ...mapGetters({
      isLoading: 'vaults/isLoading',
      isError: 'vaults/isError',
      vaults: 'vaults/all',
      included: 'vaults/included',
      selectedVaultFileIds: 'vaults/selectedVaultFileIds'
    }),
    selectableVaults() {
      return this.vaults.filter((vault) => {
        return (
          (this.families.length && (!vault.relationships.family.data ||
            this.families.find((f) => {
              return vault.relationships.family.data.id === f.id.toString()
            }))
          ) || (!this.families.length && !vault.relationships.family.data)
        )
      })
    },
    attachments() {
      return this.included && this.included.filter((included) => {
        return included.type.match(/attachment/) && this.currentVault &&
          parseInt(this.currentVault.id) === included.attributes.vault_id
      })
    },
    boxes() {
      return this.included && this.included.filter((included) => {
        return included.type.match(/box/) && this.currentVault &&
          included.relationships.vault.data.id === this.currentVault.id
      })
    },
    mediaFiles() {
      return this.included && this.included.filter((included) => {
        return included.type.match(/media_file/)
      })
    },
    selectedMediaFiles() {
      return this.mediaFiles.filter((mediaFile) => {
        return mediaFile.relationships.attachments.data.some((attachment) => {
          return this.selectedVaultFileIds.includes(attachment.id)
        })
      })
    },
    filteredAttachments() {
      let boxedAttachments = this.attachments

      if (this.currentBox) {
        boxedAttachments = boxedAttachments.filter((attachment) => {
          return attachment.relationships.box.data &&
            attachment.relationships.box.data.id === this.currentBox.id
        })
      } else {
        boxedAttachments = boxedAttachments.filter((attachment) => {
          return !attachment.relationships.box.data
        })
      }

      const groupedAttachments = boxedAttachments.map((attachment) => {
        attachment.groupDate =
          this.$moment(attachment.attributes.created_at).format('LL')
        return attachment
      })
      return this.groupBy(groupedAttachments, 'groupDate')
    }
  },
  async created() {
    await this.loadVaults({
      include: 'boxes,attachments,media_files'
    })
  },
  methods: {
    ...mapActions({
      loadVaults: 'vaults/loadAll',
      successFlashMessage: 'successFlashMessage',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments'
    }),
    isSelectedVault(vault) {
      return this.currentVault && this.currentVault.id === vault.id
    },
    insertAttachments() {
      this.$emit('insert-media-files', this.selectedMediaFiles)
    },
    selectVault(vault) {
      this.currentVault = vault
      this.currentBox = null
    },
    groupBy(xs, key) {
      return xs.reduce((rv, x) => {
        (rv[x[key]] = rv[x[key]] || []).push(x)
        return rv
      }, {})
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
