<template>
  <DialogContent
    :title="contentTitle"
    :close-global-dialog="$$(contentConfiguration, 'closeGlobalDialog')"
    :justify-center="false"
    class="dialog-content--upload"
    @close="closeUploadDialog"
  >
    <template #actions>
      <v-btn
        large
        rounded
        outlined
        color="primary"
        elevation="0"
        class="ma-2"
        min-width="170"
        :disabled="!uploadedFiles.length || loading"
        @click="dialogCallback"
      >
        {{ $i18n.t("uploader_modal.insert_btn") }}
      </v-btn>
    </template>

    <template #content>
      <div class="file-selector">
        <div class="file-selector__sidebar"></div>

        <div class="file-selector__content">
          <div class="file-type">
            <v-icon color="#4B4B4B" class="file-type__icon"
              >mdi-laptop-mac</v-icon
            >
            <h4 class="file-type__title">
              {{ $i18n.t("uploader_modal.my_device") }}
            </h4>
          </div>
          <input
            :key="key"
            type="file"
            name="file"
            :multiple="isMultiple"
            id="file-input"
            class="d-none"
            @change="onChange"
          />
          <label
            class="file-dragzone"
            for="file-input"
            @drop.prevent="onDrop($event)"
            @dragover.prevent="dragover = true"
            @dragenter.prevent="dragover = true"
            @dragleave.prevent="dragover = false"
            :class="{ 'active-animatioon': dragover }"
          >
            <div class="mx-auto d-flex w--100 justify-center">
              <span>
                <v-img
                  :src="require('@/assets/images/icons/note-plus.svg')"
                  contain
                  height="48.51px"
                />
              </span>
              <div class="dragzone-area">
                <h3 class="dragzone-area__title">
                  {{ $i18n.t("uploader_modal.drop_area_title") }}
                </h3>

                <h4 class="dragzone-area__subtitle">
                  {{ $i18n.t("uploader_modal.drop_area_subtitle") }}
                </h4>
              </div>
            </div>
          </label>
          <ul class="dragzone-list">
            <li
              class="dragzone-list__item"
              :class="file.error && 'dragzone-list__item--error'"
              v-for="file in reversedFiles"
              :key="file.tempId"
            >
              <span>
                <v-img
                  class="dragzone-list__image"
                  :src="file.cover"
                  contain
                  height="72px"
                  width="72px"
                />
              </span>
              <div class="dragzone-item__inner">
                <div class="dragzone-item__spacer">
                  <div class="dragzone-item__wrapper">
                    <div class="d-flex mt-2">
                      <UploadDialogFileTitle
                        :file-name="
                          $$(renamedFileNames, file.tempId, 'name') || file.name
                        "
                        :edit-mode="
                          Boolean($$(renamedFileNames, file.tempId, 'toggle'))
                        "
                        @update:file-name="onRenameInput(file.tempId, $event)"
                      >
                        <v-btn
                          v-if="!file.error && allowEditName"
                          class="dragzone-name-btn ml-8"
                          color="primary"
                          elevation="0"
                          rounded
                          plain
                          text
                          @click="onRenameFile(file.tempId)"
                        >
                          <v-icon class="ml-0" right>
                            mdi-pencil-outline
                          </v-icon>
                          <span class="pl-1"
                            >({{ $i18n.t("uploader_modal.rename_btn") }})</span
                          >
                        </v-btn>
                      </UploadDialogFileTitle>
                    </div>
                    <span class="dragzone-wrapper__size"
                      >{{ file.uploadedSize
                      }}{{ $i18n.t("uploader_modal.kb") }} / {{ file.size
                      }}{{ $i18n.t("uploader_modal.kb") }}</span
                    >
                    <v-progress-linear
                      class="dragzone-wrapper__progressbar"
                      background-color="transparent"
                      color="secondary"
                      :value="file.uploadedPercentage"
                    ></v-progress-linear>
                  </div>
                </div>

                <div v-if="file.error" class="dragzone-error col-auto">
                  <v-icon class="dragzone-error__icon" color="error" size="26px"
                    >mdi-information</v-icon
                  >
                  <span class="dragzone-error__info" :title="file.error">{{
                    file.error
                  }}</span>
                </div>

                <v-btn icon @click="onRemove(file.tempId)">
                  <v-icon big>mdi-close</v-icon>
                </v-btn>
              </div>
            </li>
          </ul>
        </div>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import { cloneDeep as _cloneDeep } from 'lodash'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import UploadDialogFileTitle from '@/components/Dialogs/UploadDialogFileTitle'

import { generateId, pick, pipeFunctions, toArray } from '@/utils/functions'

import Uploader from '@/utils/uploader'

export default {
  name: 'UploadDialog',
  components: { DialogContent, UploadDialogFileTitle },
  props: {
    configuration: {
      type: Object,
      default: () => null
    }
  },
  data() {
    return {
      dragover: false,

      key: 1,
      loading: false,

      files: [],
      blobs: [],

      uploadedFiles: [],
      selectedFiles: [],

      uploads: {},

      renamedFileNames: {}
    }
  },
  computed: {
    ...mapState('layout', ['dialog']),

    contentConfiguration() {
      return this.configuration || this.dialog
    },
    contentTitle() {
      return this.contentConfiguration?.title || this.$i18n.t('uploader_modal.title')
    },

    allowEditName() {
      return this.contentConfiguration?.data?.editName ?? false
    },
    isMultiple() {
      return this.contentConfiguration?.data?.multiple ?? false
    },
    hasUploadingProcess() {
      return Object.values(this.uploads).length > 0
    },

    reversedFiles() {
      return [...this.files].reverse()
    },
  },
  methods: {
    async dialogCallback() {
      if (this.contentConfiguration?.data?.callback) {
        try {
          this.isLoading()
          let selectedFiles = this.uploadedFiles
          let selectedBlobs = this.filterByUploaded(this.blobs)

          if (!(selectedFiles.length || selectedBlobs.length)) throw new Error('something goes wrong!')

          // replace original name with renamed value
          selectedFiles = this.replaceOriginalName(_cloneDeep(selectedFiles), 'filename')

          await this.contentConfiguration.data.callback(selectedFiles, selectedBlobs)
        } catch (error) {
          console.error(error)
        } finally {
          this.isLoaded()
          this.closeUploadDialog()
        }
      }
      else {
        console.error('no callback function provided!')
      }
    },
    ...mapActions({
      closeDialog: 'layout/closeDialog',
    }),
    /* ---------------------------- events functions ---------------------------- */
    onChange({ target }) {
      this.key = this.key + 1

      if (!this.isMultiple) {
        // stop uploading and remove file
        this.getTempIds(this.files).forEach(this.onRemove)
      }

      const files = this.prepareFiles(target.files)

      this.pushFiles(files)
      this.pushBlobs(files)
      this.processFiles(files)
    },
    onDrop({ dataTransfer }) {
      this.dragover = false
      let rawFiles = dataTransfer.files

      if (!this.isMultiple) {
        // stop uploading and remove file
        this.getTempIds(this.files).forEach(this.onRemove)
        rawFiles = [dataTransfer.files[0]]
      }

      const files = this.prepareFiles(rawFiles)

      this.pushFiles(files)
      this.pushBlobs(files)
      this.processFiles(files)

    },
    onRemove(id) {
      this.uploads?.[id]?.stopUploading()

      const index = this.getFileIndexById(id)

      const cover = this.files[index].cover

      this.$delete(this.files, index)
      this.$delete(this.uploads, id)
      this.$delete(this.renamedFileNames, id)

      const blobIndex = this.blobs.findIndex(blob => blob.tempId == id)
      this.$delete(this.blobs, blobIndex)

      const uploadedFileIndex = this.uploadedFiles.findIndex(obj => obj.tempId == id)
      this.$delete(this.uploadedFiles, uploadedFileIndex)

      if (cover) {
        this.revokeUrl(cover)
      }
    },
    onRenameFile(id) {
      const getNewRenamedObj = () => ({
        name: this.files[this.getFileIndexById(id)].name,
        toggle: true
      })

      const toggleState = this.renamedFileNames?.[id]?.toggle
      switch (true) {
        case toggleState !== undefined && toggleState === true:
          this.$set(this.renamedFileNames[id], 'toggle', false)
          break;

        case toggleState !== undefined && toggleState === false:
          this.$set(this.renamedFileNames[id], 'toggle', true)
          break;

        default:
          this.renamedFileNames = { ...this.renamedFileNames, [id]: getNewRenamedObj() }
          break;
      }
    },
    onRenameInput(id, event) {
      this.$set(this.renamedFileNames[id], 'name', event)
    },
    /* ---------------------------------- utils --------------------------------- */
    replaceOriginalName(arr, nameKey) {
      arr.forEach((item) => {
        const { tempId, ...rest } = item
        item[nameKey] = this.renamedFileNames?.[tempId]?.name || rest[nameKey]
      })
      return arr
    },
    closeUploadDialog() {
      const closeIt = this.contentConfiguration?.closeDialog ?? this.closeDialog
      closeIt()
    },
    prepareFiles(files) {
      return pipeFunctions(toArray, this.appendId)(files)
    },
    pushFiles(files) {
      this.files.push(...files.map(this.getNewFile))
    },
    pushBlobs(files) {
      this.blobs.push(...files)
    },
    getNewFile(blob) {
      return ({
        ...pick(blob, ['tempId', 'name', 'size']),
        cover: this.generateCoverUrl(blob),
        uploadedStatus: false,
        uploadedSize: 0,
        uploadedPercentage: 0,
        error: null,
      })
    },
    appendId(files) {
      // cannot use here .map() because map return a new copy of array, so it'll corrupt files
      files.forEach(el => {
        el.tempId = generateId()
      })
      return files
    },
    generateCoverUrl(blob) {
      const matchValues = (matchArray) => matchArray.some(match => blob.type?.match(match))
      let result

      switch (true) {
        case matchValues([/jpeg/, /png/, /gif/]):
          result = this.toObjectUrl(blob)
          break

        case matchValues([/audio/]):
          result = require('@/assets/images/vault/audio.svg')
          break

        default:
          result = require('@/assets/images/vault/document.svg')
          break
      }

      return result
    },
    revokeUrl(url) {
      URL.revokeObjectURL(url)
    },
    pickCoverUrl(tempId) {
      return this.files[this.getFileIndexById(tempId)].cover
    },
    pickResolved(results) {
      return results.filter((item) => item.status === 'fulfilled').map(el => el.value)
    },
    pickRejected(results) {
      return results.filter((item) => item.status === 'rejected').map(el => el.reason)
    },
    isLoading() {
      this.loading = true
    },
    isLoaded() {
      this.loading = false
    },
    getTempIds: (arr) => arr.map(file => file.tempId),
    filterByUploaded(files) {
      return files.filter(f => this.getTempIds(this.uploadedFiles).includes(f.tempId))
    },
    /* --------------------------------- request -------------------------------- */
    async processFiles(files) {
      try {
        let requests = []
        const uploads = this.getUploadPromises(files)

        requests = uploads.map(({ uploadPromise }) => uploadPromise)

        this.uploads = uploads.reduce((obj, { uploader, file }) => {
          if (uploader) obj[file.tempId] = uploader
          return obj
        }, {})

        const settledFiles = await this.promisifySettled(requests)

        this.uploadedFiles.push(...this.pickResolved(settledFiles))

        const rejected = this.pickRejected(settledFiles)
        this.setErrors(rejected)

      } catch (err) {
        console.error(err)
      } finally {
        // remove Uploader instances
        Object.keys(this.uploads).forEach(key => {
          this.$delete(this.uploads, key)
        });
      }
    },
    setErrors(rejected) {
      rejected.forEach(({ error, tempId }) => {
        const index = this.getFileIndexById(tempId)

        this.$set(this.files[index], 'error', error)
      })
    },
    getUploadPromises(files) {
      return files.map(this.uploadSingle)
    },
    promisifySettled(promiseArr) {
      return Promise.allSettled(promiseArr)
    },
    checkExtension(file) {
      return this.$directUploadAllowedFileTypes.includes(file.type)
    },
    uploadSingle(file) {
      if (!this.checkExtension(file)) {
        return {
          uploadPromise: Promise.reject({
            tempId: file.tempId,
            error: this.$i18n.t("uploader_modal.not_allowed")
          }),
          uploader: null,
          file
        }
      }

      const { $updateUploadedStatus, $directUploadPath, $updateProgress } = this

      const uploader = new Uploader(file, $directUploadPath, {
        $updateUploadedStatus,
        $updateProgress
      })

      const uploadPromise = uploader.upload()

      return { uploadPromise, uploader, file }
    },

    /* ------------------------------ class helpers ----------------------------- */
    toObjectUrl: blob => URL.createObjectURL(blob),
    getFileIndexById(tempId) {
      return this.files.findIndex(el => el.tempId === tempId)
    },
    $updateUploadedStatus({ tempId }) {
      const index = this.getFileIndexById(tempId)

      this.$set(this.files[index], 'uploadedStatus', true)
    },
    $updateProgress(percent, file, event) {
      const { tempId } = file
      const index = this.getFileIndexById(tempId)

      this.$set(this.files[index], 'uploadedSize', event.loaded)
      this.$set(this.files[index], 'uploadedPercentage', percent)
    }
  }
}
</script>

<style lang="scss" src="./UploadDialog.scss"></style>
