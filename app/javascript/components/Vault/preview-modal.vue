<template>
  <div
    id="attachment-preview-modal"
    class="modal attachment-preview-modal active"
  >
    <div class="modal-container">
      <div class="modal-content">
        <div class="modal-inner-wrapper">
          <a
            class="close"
            :title="$i18n.t('vaults.attachment_modal.close')"
            @click="$modal.hide(`preview-modal-${mediaFile.id}`)"
          />
          <div class="modal-header">
            <div class="file-name">
              {{ mediaFile.attributes.filename }}
            </div>
          </div>

          <div class="image-container">
            <div class="vertical-center">
              <div class="vc-cell">
                <div
                  v-if="mediaFile.attributes.mimetype.match(/image/)"
                  class="image-wrapper"
                >
                  <img
                    :src="mediaFile.attributes.url"
                    :alt="mediaFile.attributes.filename"
                  >
                </div>

                <div
                  v-if="mediaFile.attributes.mimetype.match(/audio/)"
                  class="audio-wrapper"
                >
                  <audio
                    :src="mediaFile.attributes.url"
                    class="audio"
                    file-load
                    controls
                  />
                </div>
                <div
                  v-if="mediaFile.attributes.mimetype.match(/video/)"
                  class="video-wrapper"
                >
                  <video
                    pause-overlay
                    controls
                  >
                    <source
                      file-load
                      :src="mediaFile.attributes.url"
                    >
                  </video>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    mediaFile: {
      type: Object,
      required: true
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
