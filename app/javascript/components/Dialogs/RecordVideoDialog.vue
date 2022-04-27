<template>
  <DialogContent
      title="Record Video"
      background-color="#E8E4FF"
      margin-bottom="0"
      @close="$emit('close')"
  >
    <template v-slot:content>
      <div class="pt-15 pb-5 px-0">
        <v-row v-if="!isDeviceReady">
          <v-col class="d-flex justify-center">
            <p class="record-video__call-to-action">
              {{ $i18n.t("record_dialog.click_to_record") }}
            </p>
          </v-col>
        </v-row>
        <v-row>
          <video id="video-recorder" class="video-js vjs-default-skin"></video>
        </v-row>
        <div
            v-if="isDeviceReady && !isRecordingFinished"
            class="record-video__controls d-flex flex-row align-center justify-center"
        >
          <div class="record-video__controls-container d-flex flex-row justify-start align-center mr-5">
              <v-btn
                  class="ml-3"
                  color="primary"
                  fab
                  @click="stopRecording"
              >
                <v-icon>mdi-stop</v-icon>
              </v-btn>
              <span class="record-video__timestamp ml-2">
                {{ timestamp }}
              </span>
            </div>
          <v-btn
                fab
                :color="isRecording ? '#4B4B4B' : 'primary'"
                @click="toggleRecording"
            >
              <v-icon v-if="isRecording" color="white">mdi-pause</v-icon>
              <v-icon v-else>mdi-camera</v-icon>
            </v-btn>
        </div>
        <v-row v-if="isRecordingFinished">
          <v-col>
            <v-btn
                color="primary"
                outlined
                @click="play"
                :disabled="isRecording"
            >
              Play
            </v-btn>
          </v-col>
          <v-col class="d-flex justify-end">
            <v-btn
                class="mr-4"
                color="primary"
                text
                @click="closeDialog"
                :disabled="isUploading"
            >
              Discard
            </v-btn>
            <v-btn
                color="primary"
                @click="saveRecording"
                :disabled="isUploading"
            >
              <v-progress-circular
                  v-if="isUploading"
                  indeterminate
                  color="white"
                  class="mr-1"
              />
              <span v-else>Save</span>
            </v-btn>
          </v-col>
        </v-row>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import { mapActions, mapState } from "vuex";
import { DirectUpload } from '@rails/activestorage'

import Trix from 'trix'

import DialogContent from "@/components/Layout/Dialog/DialogContent";

import 'video.js/dist/video-js.min.css';
import videojs from 'video.js';

import 'webrtc-adapter'
// eslint-disable-next-line no-unused-vars
import RecordRTC from 'recordrtc';
import 'videojs-record/dist/css/videojs.record.css';
// eslint-disable-next-line no-unused-vars
import Record from 'videojs-record/dist/videojs.record.js';

export default {
  name: "RecordVideoDialog",
  components: {
    DialogContent
  },
  data: () => ({
    isDeviceReady: false,
    isRecording: false,
    isRecordingFinished: false,
    isUploading: false,
    player: undefined,
    timestamp: '0:00',
    options: {
      controls: false,
      autoplay: false,
      fluid: false,
      loop: false,
      bigPlayButton: false,
      plugins: {
        // configure videojs-record plugin
        record: {
          maxLength: undefined,
          audio: true,
          video: true,
          debug: true
        },
      }
    }
  }),
  computed: {
    ...mapState({
      dialog: (state) => state.layout.dialog
    }),
  },
  mounted() {
    this.player = videojs('video-recorder', this.options)
    this.player.on('deviceReady', () => {
      this.isDeviceReady = true
      this.startRecording()
    })
    // user completed recording and stream is available
    this.player.on('finishRecord', () => {
      this.isRecordingFinished = true
    })

    this.player.on('progressRecord', () => {
      const duration = this.$moment.duration(this.player.record().getDuration(), 'seconds')
      this.timestamp = this.$moment.utc(duration.as('milliseconds')).format('mm:ss')
    })

    this.player.on('error', (element, error) => {
      console.warn(error);
    })

    this.player.on('deviceError', () => {
      console.error('device error:', this.player.deviceErrorCode);
    })
  },
  beforeDestroy() {
    if (this.player) {
      this.player.dispose();
    }
  },
  methods: {
    ...mapActions({
      closeDialog: "layout/closeDialog"
    }),
    saveRecording() {
      this.isUploading = true
      const upload = new DirectUpload(
          this.player.recordedData,
          this.$directUploadPath
      )
      upload.create((error, blob) => {
        if (error) {
          throw new Error(`Direct upload failed: ${error}`)
        } else {
          // get rich editor instance
          const element = document.getElementById(this.dialog.data.editorId)
          const attrs = {
            sgid: blob.attachable_sgid,
            href: blob.signed_id,
            url: blob.signed_id,
            filename: "recording.webm",
            contentType: "audio/webm",
            width: 1,
            height: 1
          }
          const attachment = new Trix.Attachment(attrs)
          element.editor.insertAttachment(attachment)
          this.isUploading = false
          this.closeDialog()
        }
      })
    },
    play() {
      this.player.play()
    },
    pause() {
      this.player.pause()
    },
    startRecording() {
      this.player.record().start()
      this.isRecording = true
    },
    stopRecording() {
      this.player.record().stop()
      this.isRecording = false
    },
    resumeRecording() {
      this.player.record().resume()
      this.isRecording = true
    },
    pauseRecording() {
      this.player.record().pause()
      this.isRecording = false
    },
    toggleRecording() {
      if (this.isRecording) {
        this.pauseRecording()
      } else {
        this.resumeRecording()
      }
    },
  },
};
</script>
<style lang="scss" scoped>
#video-recorder {
  width: 100%;
  max-height: 44vh;
  background-color: #E8E4FF;
}
.record-video {
  &__call-to-action {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    color: $color-tertiary;
  }
  &__controls {
    position: absolute;
    bottom: 40px;
    width: calc(100% - 24px);
  }
  &__controls-container {
    width: 152px;
    height: 72px;
    left: 598px;
    top: 673px;
    background: rgba(75, 75, 75, 0.67);
    border-radius: 60px;
  }
  &__timestamp {
    font-family: Lato;
    font-style: normal;
    font-weight: 600;
    font-size: 25px;
    line-height: 30px;
    color: #E75739;
  }
}
</style>
