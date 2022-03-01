<template>
  <div
    id="rich-editor"
    class="rich-editor"
    ref="rich-editor-wrapper"
  >
    <div
      :class="{
        containerClasses,
        'rich-editor--sticky': isSticky
      }"
    >
      <div v-intersect.quiet="{
          handler: intersectTop,
          options: {
            rootMargin: '-130px 0px 0px 0px',
            threshold: 0
          }
        }"/>
      <input
        :id="input"
        :value="value"
        spellcheck="true"
        type="hidden"
        name="content"
      >
      <trix-editor
        ref="editor"
        class="trix-content editor"
        :class="{ 'highlight-drop': highlighted}"
        :input="input"
        :placeholder="value ? undefined : $i18n.t('sections.body_placeholder')"
        @trix-initialize="trixAddAdditionalButtons"
        @trix-change="emitChange"
        @trix-file-accept="validateAttachment"
        @trix-attachment-add="saveAttachment"
        @trix-selection-change="configurePlaceholders"
        @dragover="highlightDropzone"
        @dragleave="lowlightDropzone"
        @drop="lowlightDropzone"
      />
      <div v-intersect.quiet="{
          handler: intersectBottom,
          options: {
            rootMargin: '-100px 0px 0px 0px',
            threshold: 0
          }
        }"/>

<!--      <MountingPortal
        mount-to="#vue-modal"
        append
      >
        <modal
          :name="`insert-vault-modal&#45;&#45;${_uid}`"
          @before-open="setAttachVaultMode"
          @before-close="setViewVaultMode"
        >
          <vault-modal
            :current-user="currentUser"
            :families="families"
            :parent-uid="_uid"
            @insert-media-files="insertMediaFiles"
          />
        </modal>
      </MountingPortal>-->
    </div>
  </div>
</template>

<script>
import Vue from 'vue'
import Trix from 'trix'
import 'trix/dist/trix.css'
import { mapActions, mapGetters } from 'vuex'
import { DirectUpload } from '@rails/activestorage'

Trix.config.lang.urlPlaceholder = 'Enter a URL (i.e. http://example.com)'

Trix.config.textAttributes.underline = {
  tagName: 'u',
  inheritable: true
}

Trix.config.blockAttributes.heading1.tagName = 'h2'

export default {
  props: {
    currentUser: {
      type: Object,
      required: true
    },
    input: {
      type: String,
      default: 'rich_input'
    },
    value: {
      type: String,
      required: true
    },
    savingStatus: {
      type: String,
      default: ''
    },
    containerClass: {
      type: String,
      default: 'trix-container'
    },
    families: {
      type: Array,
      default: () => []
    },
    uploadInProgress: Boolean,
    blurred: Boolean,
    initialState: Boolean
  },
  data () {
    return {
      firstInit: true,
      attachments: [],
      highlighted: false,
      hoverAttach: null,
      topEditorIsVisible: false,
      bottomEditorIsVisible: false,
      isSticky: false
    }
  },
  computed: {
    ...mapGetters([
      'showUploadInProgressBeforeUnload'
    ]),
    containerClasses () {
      let classes = { 'blurred': this.blurred }
      classes[this.containerClass] = true

      return classes
    },
  },
  mounted () {
    window.addEventListener('beforeunload', this.notifyUploadingAttachment)
  },
  methods: {
    ...mapActions({
      uploadInProgressBeforeUnloadOn: 'uploadInProgressBeforeUnloadOn',
      uploadInProgressBeforeUnloadOff: 'uploadInProgressBeforeUnloadOff',
      setAttachVaultMode: 'vaults/setAttachVaultMode',
      setViewVaultMode: 'vaults/setViewVaultMode',
      clearSelectedAttachments: 'vaults/clearSelectedAttachments'
    }),
    intersectTop (entries) {
      this.topEditorIsVisible = entries[0].isIntersecting
      this.checkIfVisible()
    },
    intersectBottom (entries) {
      this.bottomEditorIsVisible = entries[0].isIntersecting
      this.checkIfVisible()
    },
    checkIfVisible(){
      let visibility = false
      if (this.topEditorIsVisible || this.bottomEditorIsVisible) {
        visibility = true
      } else {
        const rect = this.$refs['rich-editor-wrapper'].getBoundingClientRect()
        visibility = rect.bottom > 115 && rect.top < (window.innerHeight - 115)
      }
      this.isSticky = visibility && !this.topEditorIsVisible && !this.bottomEditorIsVisible
    },
    notifyUploadingAttachment (event) {
      if (!this.showUploadInProgressBeforeUnload) return
      let inProgress = false
      this.attachments.forEach((attachment) => {
        if (attachment.attachment.uploadProgress !== 100) inProgress = true
      })

      if (inProgress) {
        event.returnValue = this.$i18n.t('stories.upload-in-progress.title')
      }
    },
    emitChange (event) {
      if (this.attachments.length > 0) return
      if (this.firstInit) return this.firstInit = false

      this.$emit('editor-change', event)
    },
    validateAttachment (event) {
      let maxFileSize = 1024 * 1024 * 4000

      const allowedFileTypes = [
        'text/plain',
        'application/pdf',
        'application/zip',
        'application/rar',
        'image/jpeg',
        'image/png',
        'image/gif',
        'audio/mp3',
        'audio/mpeg',
        'video/mp4',
        'video/mpeg',
        'video/quicktime',
        'application/msword',
        'application/vnd.ms-excel',
        'application/vnd.ms-powerpoint',
        'application/vnd.openxmlformats-officedocument.' +
          'wordprocessingml.document',
        'application/vnd.openxmlformats-officedocument.' +
          'spreadsheetml.sheet',
        'application/vnd.openxmlformats-officedocument.' +
          'presentationml.presentation'
      ]

      if (event.file.type.search(/image\//i) >= 0) {
        maxFileSize = 1024 * 1024 * 100
      }

      if (event.file.size > maxFileSize) {
        alert(this.$i18n.t('attachment.errors.size_limit'))
        event.preventDefault()
      }
      
      if (!allowedFileTypes.includes(event.file.type)) {
        alert(this.$i18n.t('attachment.errors.format_not_allowed'))
        event.preventDefault()
      }

      const editor = event.target
        .closest('#rich-editor')
        .querySelector('trix-editor')
        .editor
      if (editor.attributeIsActive('heading1')) {
        alert(this.$i18n.t('attachment.errors.attachment_on_title'))
        event.preventDefault()
      }
    },
    saveAttachment (event) {
      if (event.attachment.file) {
        this.attachments.push(event.attachment)
        this.$parent.$emit('update:uploadInProgress', true)
        this.$emit('update:savingStatus', 'started')
        const upload = new DirectUpload(
          event.attachment.file,
          this.$directUploadPath,
          this
        )
        upload.create((error, blob) => {
          if (error) {
            this.$emit('update:savingStatus', 'failed')
            throw new Error(`Direct upload failed: ${error}`)
          } else {
            event.attachment.setAttributes({
              sgid: blob.attachable_sgid,
              href: blob.signed_id,
              url: blob.signed_id
            })
            this.$emit('update:savingStatus', 'finished')
          }
          this.attachments = this.attachments.filter((attachment) => {
            return attachment !== event.attachment
          })
          this.$parent.$emit(
            'update:uploadInProgress',
            this.attachments.length > 0
          )
          if (this.attachments.length === 0) this.$emit('editor-change', event)
        })
      }
    },
    directUploadWillStoreFileWithXHR (xhr) {
      xhr.upload.addEventListener('progress', event => {
        const attachment = this.findAttachment(event.total)
        const progress = event.loaded / event.total * 100
        attachment.setUploadProgress(progress)
      })
    },
    findAttachment (attachmentSize) {
      return this.attachments.find((attachment) => {
        return attachment.file.size === attachmentSize
      })
    },
    configurePlaceholders (event) {
      const editor = event.target.editor
      const currentContent = editor.getDocument().toString()
      const placeholderTitle = this.$i18n.t('sections.title_placeholder')
      const placeholderBody = this.$i18n.t('sections.body_placeholder')

      const titleStart = currentContent.indexOf(placeholderTitle)
      const titleEnd = titleStart + placeholderTitle.length
      const bodyStart = currentContent.indexOf(placeholderBody)
      const bodyEnd = bodyStart + placeholderBody.length

      if (titleStart >= 0 &&
          editor.getSelectedRange()[0] <= titleEnd &&
          editor.getSelectedRange()[1] > titleStart) {
        editor.setSelectedRange([titleStart, titleEnd])
      }

      if (bodyStart >= 0 &&
          editor.getSelectedRange()[0] <= bodyEnd &&
          editor.getSelectedRange()[1] > bodyStart) {
        editor.setSelectedRange([bodyStart, bodyEnd])
      }
    },
    trixAddAdditionalButtons (event) {
      const target = event.target
      const toolbar = document.getElementById(target.getAttribute('toolbar'))

      this.trixAddLinkButtonsToToolbar(target, toolbar)
      this.trixAddUnderlineButtonToToolbar(target, toolbar)
      //TODO
      //this.trixAddAttachmentButtonToToolbar(target, toolbar)
      //this.trixAddVaultButtonToToolbar(target, toolbar)
      //this.trixAddImageTooltipAfterToolbar(target, toolbar)
    },
    trixAddUnderlineButtonToToolbar (target, toolbar) {
      const trixTextButtons = toolbar
        .querySelector('.trix-button-group--text-tools')

      const underlineHTML = `
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-underline"
          data-trix-attribute="underline" title="underline"
          tabindex="-1"
        >U</button>
      `

      trixTextButtons.innerHTML += underlineHTML
    },
    trixAddLinkButtonsToToolbar (target, toolbar) {
      const trixFileButtons = toolbar
        .querySelector('.trix-button-group--file-tools')

      const LinkButton = Vue.extend({
        parent: this,
        methods: {
          overIcon () {
            this.$parent.changeHoverAttach('Link')
          },
          leaveIcon () {
            this.$parent.changeHoverAttach(null)
          }
        },
        template: `
        <button type="button" class="trix-button trix-button--icon
          trix-button--icon-link trix-button--icon-link_editor"
          data-trix-attribute="href" data-trix-action="link"
          data-trix-key="k" title="Link" tabindex="-1"
          @mouseover="overIcon"
          @mouseleave="leaveIcon"
        >Link</button>
        `
      })

      let linkDiv = document.createElement('div')
      linkDiv.setAttribute('id', 'link-button')
      trixFileButtons.appendChild(linkDiv)

      new LinkButton().$mount('#link-button')
    },
    trixAddVaultButtonToToolbar (target, toolbar) {
      const trixFileButtons = toolbar
        .querySelector('.trix-button-group--file-tools')

      const VaultsButton = Vue.extend({
        parent: this,
        methods: {
          showVaultsModal (event) {
            this.$parent.showVaultsModal(event)
          },
          overIcon () {
            this.$parent.changeHoverAttach('Vault')
          },
          leaveIcon () {
            this.$parent.changeHoverAttach(null)
          }
        },
        template: `
        <button
          type="button"
          class="trix-button trix-button--icon trix-button--icon-vaults"
          data-trix-attribute="x-attach" title="Add from Vault"
          tabindex="-1"
          @click="showVaultsModal"
          @mouseover="overIcon"
          @mouseleave="leaveIcon"
        >Add from Vault</button>
        `
      })

      let div = document.createElement('div')
      div.setAttribute('id', 'vaults-button')
      trixFileButtons.appendChild(div)

      new VaultsButton().$mount('#vaults-button')
    },
    trixAddImageTooltipAfterToolbar (target, toolbar) {
      const ImageTooltip = Vue.extend({
        parent: this,
        computed: {
          title () {
            if (this.$parent.hoverAttach) {
              return this.$parent.hoverAttach
            } else {
              return null
            }
          }
        },
        template: `
        <span
          class="image-tooltip-source"
          :class="{
            'attach': title && title.includes('Attach'),
            'facebook': title && title.includes('Facebook'),
            'instagram': title && title.includes('Instagram'),
            'vault': title && title.includes('Vault'),
            'link': title && title.includes('Link')
          }"
        >{{title}}</span>
        `
      })

      const tooltipHTML = `
        <div
          id="image-tooltip-source"
        ></div>
      `

      if (this.initialState) {
        const trixButtonRow = toolbar
          .querySelector('.trix-button-group--file-tools')
        trixButtonRow.insertAdjacentHTML('beforeend', tooltipHTML)
        new ImageTooltip().$mount('#image-tooltip-source')
      }
    },
    trixAddAttachment () {
      const fileInput = document.createElement('input')
      const editor = this.$refs.editor.editor
      const selection = editor.getSelectedRange()

      fileInput.setAttribute('type', 'file')
      fileInput.setAttribute('multiple', '')
      fileInput.setAttribute('style', 'display: none;')

      document.querySelector('body').appendChild(fileInput)

      fileInput.addEventListener('change', () => {
        this.adjustSelection(editor, selection)
        editor.insertFiles(fileInput.files)
      })

      fileInput.click()
    },
    onClose () {
      this.setFileStackUploadCountEditor(0)
      this.fileStackCount = this.getFileStackUploadCountEditor
    },
    onFileSelected (event) {
      this.fileStackCount += event.size
      this.setFileStackUploadCountEditor(this.fileStackCount)
      let result1, result2

      if (this.$route.name === 'community') {
        result1 = this.fileStackCount + this.familyCurrentUserSize
        result2 = this.fileStackCount + this.familyConnectorSize
      } else if (this.$route.name === 'member') {
        result1 = this.fileStackCount + this.kinshipCurrentUserSize
        result2 = this.fileStackCount + this.kinshipConnectorSize
      } else {
        result1 = this.fileStackCount + this.sectionCurrentUserSize
        result2 = this.fileStackCount + this.sectionConnectorSize
      }

      if (result1 <= 21474825484 && result2 <= 21474825484) {
        console.log('allow')
      } else {
        console.log('not allow')
        this.setFileStackUploadCountEditor(this.fileStackCount - event.size)
        this.fileStackCount = this.getFileStackUploadCountEditor
        this.failureFlashMessage('file is too big')
        let uploadBtn = document.getElementsByClassName('fsp-button-upload')
        uploadBtn.classList.add('guestUser')
      }
    },
    insertAttachments (attachmentsAttributes) {
      console.log(attachmentsAttributes)
      const editor = this.$refs.editor.editor

      this.adjustSelection(editor)

      const attachments = attachmentsAttributes.map((attachmentAttributes) => {
        const attachment = new Trix.Attachment({
          sgid: attachmentAttributes.attachable_sgid,
          contentType: attachmentAttributes.mimetype,
          filename: attachmentAttributes.filename,
          filesize: attachmentAttributes.size,
          url: attachmentAttributes.url
        })

        if (attachment.isPreviewable()) {
          attachment.attributes.values.previewable = true
        } else {
          attachment.attributes.values.content = `
            <a class="download-doc" target="_blank"
                href="${attachmentAttributes.url}"
            >
              <i class="fa fa-file-o"></i>
              <span class="attachment__name">
                ${attachmentAttributes.filename}
              </span>
              <span class="attachment__size">
                ${attachmentAttributes.human_size}
              </span>
            </a>
          `
        }

        return attachment
      })

      editor.insertAttachments(attachments)
    },
    showVaultsModal () {
      this.$modal.show(`insert-vault-modal--${this._uid}`)
    },
    adjustSelection (editor, initialSelection = undefined) {
      if (initialSelection) editor.setSelectedRange(initialSelection)
      while (editor.attributeIsActive('heading1')) {
        editor.moveCursorInDirection('forward')
      }
    },
    highlightDropzone () {
      this.highlighted = true
    },
    lowlightDropzone () {
      this.highlighted = false
    },
    changeHoverAttach (source) {
      this.hoverAttach = source
    }
  }
}
</script>

<style lang="scss">
  .rich-editor {
    .trix-content.editor {
      border-top: none !important;
      border-right: 1px solid $color-light-grey !important;
      border-bottom: 1px solid $color-light-grey !important;
      border-left: 1px solid $color-light-grey !important;
      box-sizing: border-box;
      border-radius: 0 0 5px 5px;
      padding: 16px !important;
      transition: padding-top 100ms ease-out;
      &:empty:not(:focus)::before {
        font-size: 18px;
        color: #a3a3a3;
      }
      div {
        font-size: 18px;
        color: $color-text;
      }
    }
    .trix-button {
      border: none !important;
      &.trix-active {
        background: $color-medium-grey ;
      }
      &:hover {
        background: #c1c0c0;
      }
    }
    .trix-button-row {
      background: $color-light-grey;
      border-radius: 5px 5px 0 0;
      border-bottom: 1px solid $color-medium-grey;
    }
    .trix-button-group {
      border: none !important;
      margin: 3px !important;
    }
    .trix-button--icon-strike {
      display: none;
    }
    .highlight-drop {
      box-shadow: 0 0 5px rgba(81, 203, 238, 1);
      border: 2px solid rgba(81, 203, 238, 1) !important;
    }
    &--sticky {
      trix-toolbar {
        position: sticky;
        top: 114px;
        z-index: 10;
        padding-top: 16px;
      }
      .trix-content.editor {
        padding-top: 0 !important;
      }
    }
  }
  trix-toolbar {
    position: relative;
    background-color: #fff;
    padding-top: 0;
    transition: padding-top 100ms ease-out;
  }
  
  .trix-content {
    h2 {
      font-weight: normal !important;
      color: #8B78FE;
      font-size: 1em !important;
    }
    word-break: break-word !important;
  }
  .trix-button-group--file-tools div:not(:first-child) {
    border-left-color: transparent !important;
  }

  .trix-button--icon-heading-1,
  .trix-button--icon-code {
    display: none !important;
  }
  .trix-button--icon-link {
    display: none !important;
  }
  .trix-button--icon-link_editor {
    display: block !important;
  }

  .trix-button--icon-attach-files::before {
    background-image: url('data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAMgAA\
      ADICAYAAACtWK6eAAAABHNCSVQICAgIfAhkiAAAAAlwSFlzAAALEwAACxMBAJqcGAAAB4JJR\
      EFUeJzt3VuMHmUdx/FvqYXSZGkL0kKhFGqkyiEx8RAJGiJqjAfEaAx4aqrYxJgYQ7zgwhgi8\
      YZgDDExkYQLJNVEaoxyYUTQBGO4IXIUUBBaLKzQVEptYQHpLhfPEotu/8/MvPM88+6+308yN\
      /vMzvOfzfx2Ds8cQJIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZIkSZKkybJs6AImwHJgM\
      7AFOBWYIv3dDwF7gUeBx4BXhipQqm018FXgVuAAMJeZZoDbgSuBUwaoV6riLcANpA0+F4qjT\
      a8CO4F3VK5dKmYK+AFp4+4ajIWmm4H1FddD6t0FwJP0G4wjp+eAS6qtjdSj7cB/KBeOI6dr8\
      KKKFpGrqBOMI6cfA8fUWDlpFF+nfjhen66rsH6a5y67vQ8Dt9HubzcL3Ac8DOwjbehrSWMj7\
      wSObVnDduDGlr8jFbceeJbm/+0fAK4A1gTLXAV8Fvhji+XOAOf2umZSD3bQbAP+F7CV9nvoj\
      wK7G/bxJzwf0Ri5kGYb7j3AxhH6WQP8tmFfXxihH6lXTTbau4ETeuhrBfDrBv09gnsRjYFzy\
      G+sTwPreuxzFXB/g34/0WOfUifXkt9QP1Kg3/PID0TeUqBfqZW/E2+kvynY948yfc8AxxXsX\
      wptIr/3+EDB/s9q0P9FBfufaJ7g5b0n0/4UcGfB/neRLulG3luw/4lmQPK2ZNp/TxopL+mOT\
      HuuRnVkQPLOyLQ/WKGGBzLtmyrUMJEMSN5Upn26Qg25PnI1qiMDknd8pv2lCjW8mGlfVaGGi\
      WRARje3RPrQAgyIFDAgUsCASAEDIgUMiBQwIFLAgEgBAyIFDIgUMCBSwIBIAQMiBQyIFDAgU\
      sCALG2XAs8H083DlbY4vGnoAlTUCtIHRY/GB60y3INIAQMiBQyIFDAgUsCASAEDIgUMiBQwI\
      FLAgEgBAyIFDIgUMCBSwIBIAQMiBQyIFDAgUsCASAGfKCznPGBl0P4QMFOpFnVkQMr5OXBO0\
      H4+8JdKtagjD7GkgAGRAgZEChgQKWBApIABkQIGRAoYkHKWDV2ARmdApIABkQIGRAoYEClgQ\
      KSAAZECBkQKGBApYEDKcaBwCTAgUsCASAEDIgUMiBQwIFLAgEgBAyIFDIgUMCDlOFC4BBgQK\
      WBApIABkQIGRAoYEClgQKSAAZECBkQKGJByZjPtbQYSc5/KO9xiWWrBgJRzMNO+scWyzsy0/\
      7vFstSCASlnd6b9ky2WlZt3V4tlqQUDUs49mfZtwJYGyzkf+NKIfakjA1LObZn244BbiQ+1z\
      gJ+Rf4cJNeXOjIg5dxP/jvoZwP3Ad8ETjri5ycD3wLuBTZnlvFn4JGONSrDgJQzB3y/wXwnA\
      tcD+4CngWlg7/zvrm7w+9d1LVB5BqSsHbQ7P9gAnNpi/ruAna0qUisGpKzDpJPxlwos+wXgK\
      +THWzQCA1Leg8BW0iFXX2aBzwN/63GZWoABqWMn6VLtqz0s6xXgctIVMBVmQOr5KXAR8OQIy\
      3gceB+ed1RjQOq6CzgXuIZ2t4fsB75DGjS8u0BdOgoDUt8LwNXA6cCXgV8Czyww3zRpT7GVN\
      Jj4PWCmUo2alxuhVTkHgZvmJ4ApYC3pZH4/cGiQqvQGBmR8HCR/B7Aq8xBLChgQKWBApIABk\
      QIGRAoYEClgQKSAARndOH8HZJxrWxQMSN7LmfaVVaro5vhMe4nnVJYUA5KXu6lwqkoV3eQe2\
      T1QpYpFzIDkPZ9p31Slim5yteXWbeIZkLzdmfa31yiio7dl2n3hnEZ2MekO26NNzzCeJ8PLg\
      eeIa79wsOq0ZKwj3sjmSA8yjZt3ka977WDVLRIeYuXtBR7OzHNZjUJaujzTfi/puRNpZD8k/\
      k+8B1gxWHX/byXp0C+q2RfOqTcfIn+4sm2o4hbwNfL1vn+w6rTkLAf+QbzB7SI/MFfDFPAUc\
      a2PM54XFsaO5yDNHAZ+kpnnTODb5UvJuho4LTPPTfT7IjuJ9cCLxP+ZDzPsocsHSW9djGo8x\
      BvfJC/15nryx/bTDDO6vhl4tkF91w5QmybEOtKl0dxG+Nf5eWs5BXisQV37cO+hwppcIZoDH\
      iV9Iaq0twJPNKxpW4V6NOGOAe6k2Qa5D/hYwVoupdkebQ74HV65UiUbSCPsTTbMOeBG4M099\
      r+edFWtaf/T1D3kk7iY9CmCphvpfuC7jHYOcDLpHb0HWvT7MumN8FJ1l5G/rLrQBvsL4HOkk\
      +ucDcAXSV+7bRPIOdJl50+PvJYTzGPS0W0HbqD733IP6arXP0lPLy4jjYafRvqO+ukdlzsLX\
      MF/X44tDeYzpD1Dm//uJacZ4JKiayy1dAH5+7VqTE8A7y68rlInJ5HOFYYKxy3AmuJrKY1gG\
      fAp0rcIa+41Pl5j5aS+rAKuJI1BlArGHuAbjMdt9lInK0m3ePyB9peEF5pmgdtJn5U+tt5qS\
      OVtJF0W/hn5h5r+d0+xg3TZNvesh3rkOMiwVgNnA2eQxj5OIAXi9e8V7ibd9Oi3CyVJkiRJk\
      iRJkiRJkiRJkiRJkiRJkiRJkiRJkiRJkiRJUhWvAXtJhIyJQ09ZAAAAAElFTkSuQmCC');
  }

  .trix-button--icon-attach-fb::before {
    background-image: url('data:image/svg+xml;base64,PHN2ZyBhcmlhLWhpZGRlbj0idH\
      J1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhYiIgZGF0YS1pY29uPSJmYWN\
      lYm9vay1mIiByb2xlPSJpbWciIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIg\
      dmlld0JveD0iMCAwIDMyMCA1MTIiIGNsYXNzPSJzdmctaW5saW5lLS1mYSBmYS1mYWNlYm9va\
      y1mIGZhLXctMTAgZmEtMngiPjxwYXRoIGZpbGw9ImN1cnJlbnRDb2xvciIgZD0iTTI3OS4xNC\
      AyODhsMTQuMjItOTIuNjZoLTg4Ljkxdi02MC4xM2MwLTI1LjM1IDEyLjQyLTUwLjA2IDUyLjI\
      0LTUwLjA2aDQwLjQyVjYuMjZTMjYwLjQzIDAgMjI1LjM2IDBjLTczLjIyIDAtMTIxLjA4IDQ0\
      LjM4LTEyMS4wOCAxMjQuNzJ2NzAuNjJIMjIuODlWMjg4aDgxLjM5djIyNGgxMDAuMTdWMjg4e\
      iIgY2xhc3M9IiI+PC9wYXRoPjwvc3ZnPg==');
    background-size: 0.6em !important;
  }

  .trix-button--icon-attach-fb:hover {
    background-color: #3b5998;

    &::before {
      background-image: url('data:img/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFQAAA\
        CdCAQAAACAhZc2AAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAd\
        TAAAOpgAAA6mAAAF3CculE8AAAAAmJLR0QA/4ePzL8AAAAHdElNRQfjCh4SJCftMthSAAAD\
        EElEQVR42u3cP2gTYRjH8W/SVK3SaqVgUPA/FSyWilCcuujm4CAotiK4uOggggilODsoOCh\
        OurSDi5NDF8FRxEEEq/2bUjSGFiupjW1sjXUIGgfRvs/73tv3hee3JJD3ufvkee8uueO41A\
        peso42DtHKfnbQQjPrqfv92Q+WKPOVL8zxmWk+MUOBAnlm+P5rUCZxYgfH6KKTrHFlhRny5\
        JhikuFUgh3dRTenOOJmYUl1tJMrnP5jem1TTgLaTi9nHC9z2T30JtcT+PKOp/4oDziYBBPS\
        Dpd1iedJMV1C73A3KSS4m/oBepJkuupof9JMN9BbnEuaCfa/TD0MJM9k3ha6h5wHJszbTv0\
        TL0xst9GrtPmC2kz9Zoq+mHZTf9sbE5uOZil4dFp0tNcjE3lH65mjwaNT3NFur0zkh6cLfp\
        nSqW9mlpRXp3DqT3hmQoMMetwzEzKyP85dThElXvKKMQqUWGD5r2Mqkm10J1POkM94yCCz/\
        x8o6ehhR8ghrjG42sES6AEnzH7OmwyX7Ez7HDDvmTFl0L3WzKdcNi2RQLdbMpc4aV5kDq1j\
        qyW0jwXzIvPDUxMFNlowF2mqXUdefcw7uoUNFkx4LGFKoI2WJ4TC81bzlVasmPDCF9QuBen\
        Pr2/oe2mhb2gxFui3WKDi9fmG+v+GClWoQhWqUIUqNIoodO2heav1CS49VJOh3RC72wqapU\
        NQleZ1asXTzXlWKdKStj5P95G3VNLyrcZjhmLZ68djgQ7HAp2IA1oiFwd0nMVYoMQBHY0FO\
        hwLdDIWaC4OaJ6PcUAnqi/hQ0digY7GAh2LBRpJR0vVo2j40HHKsUCJAzoZC3Q0FuhILNCJ\
        GjRk6ofqH5IqdNNaa/6RYu1thovUGxVv44bFqt9w32D0u9pb89uJ7K5WPeKsrNB8C221YEK\
        jtDDkXUmhClWoQmOIQhUaehSq0NCjUIWGHoUqNPQoVKGhR6EKDT0KVWjoUahCQ49CFRp6FK\
        rQ0KNQhYYehSo09ChUoaFHoQoNPZInEdqkSVpo/ljPZeYtoNPSwp9V842xZbf8aQAAAABJR\
        U5ErkJggg==');
      background-size: 0.6em !important;
      opacity: 1;
    }
  }

  .trix-button--icon-attach-ig::before {
    background-image: url('data:image/svg+xml;base64,PHN2ZyBhcmlhLWhpZGRlbj0idH\
      J1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhYiIgZGF0YS1pY29uPSJpbnN\
      0YWdyYW0iIHJvbGU9ImltZyIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIiB2\
      aWV3Qm94PSIwIDAgNDQ4IDUxMiIgY2xhc3M9InN2Zy1pbmxpbmUtLWZhIGZhLWluc3RhZ3Jhb\
      SBmYS13LTE0IGZhLTJ4Ij48cGF0aCBmaWxsPSJjdXJyZW50Q29sb3IiIGQ9Ik0yMjQuMSAxND\
      FjLTYzLjYgMC0xMTQuOSA1MS4zLTExNC45IDExNC45czUxLjMgMTE0LjkgMTE0LjkgMTE0Ljl\
      TMzM5IDMxOS41IDMzOSAyNTUuOSAyODcuNyAxNDEgMjI0LjEgMTQxem0wIDE4OS42Yy00MS4x\
      IDAtNzQuNy0zMy41LTc0LjctNzQuN3MzMy41LTc0LjcgNzQuNy03NC43IDc0LjcgMzMuNSA3N\
      C43IDc0LjctMzMuNiA3NC43LTc0LjcgNzQuN3ptMTQ2LjQtMTk0LjNjMCAxNC45LTEyIDI2Lj\
      gtMjYuOCAyNi44LTE0LjkgMC0yNi44LTEyLTI2LjgtMjYuOHMxMi0yNi44IDI2LjgtMjYuOCA\
      yNi44IDEyIDI2LjggMjYuOHptNzYuMSAyNy4yYy0xLjctMzUuOS05LjktNjcuNy0zNi4yLTkz\
      LjktMjYuMi0yNi4yLTU4LTM0LjQtOTMuOS0zNi4yLTM3LTIuMS0xNDcuOS0yLjEtMTg0LjkgM\
      C0zNS44IDEuNy02Ny42IDkuOS05My45IDM2LjFzLTM0LjQgNTgtMzYuMiA5My45Yy0yLjEgMz\
      ctMi4xIDE0Ny45IDAgMTg0LjkgMS43IDM1LjkgOS45IDY3LjcgMzYuMiA5My45czU4IDM0LjQ\
      gOTMuOSAzNi4yYzM3IDIuMSAxNDcuOSAyLjEgMTg0LjkgMCAzNS45LTEuNyA2Ny43LTkuOSA5\
      My45LTM2LjIgMjYuMi0yNi4yIDM0LjQtNTggMzYuMi05My45IDIuMS0zNyAyLjEtMTQ3LjggM\
      C0xODQuOHpNMzk4LjggMzg4Yy03LjggMTkuNi0yMi45IDM0LjctNDIuNiA0Mi42LTI5LjUgMT\
      EuNy05OS41IDktMTMyLjEgOXMtMTAyLjcgMi42LTEzMi4xLTljLTE5LjYtNy44LTM0LjctMjI\
      uOS00Mi42LTQyLjYtMTEuNy0yOS41LTktOTkuNS05LTEzMi4xcy0yLjYtMTAyLjcgOS0xMzIu\
      MWM3LjgtMTkuNiAyMi45LTM0LjcgNDIuNi00Mi42IDI5LjUtMTEuNyA5OS41LTkgMTMyLjEtO\
      XMxMDIuNy0yLjYgMTMyLjEgOWMxOS42IDcuOCAzNC43IDIyLjkgNDIuNiA0Mi42IDExLjcgMj\
      kuNSA5IDk5LjUgOSAxMzIuMXMyLjcgMTAyLjctOSAxMzIuMXoiIGNsYXNzPSIiPjwvcGF0aD4\
      8L3N2Zz4=');
    background-size: 1.1em !important;
  }

  .trix-button--icon-attach-ig:hover::before {
    background-image: url('data:img/png;base64,iVBORw0KGgoAAAANSUhEUgAAADgAAAA4\
      CAYAAACohjseAAAABGdBTUEAALGPC/xhBQAAACBjSFJNAAB6JgAAgIQAAPoAAACA6AAAdTAAA\
      OpgAAA6mAAAF3CculE8AAAABmJLR0QA/wD/AP+gvaeTAAAAB3RJTUUH4wocEzsMJx+\NMAAAG\
      nJJREFUaN59mnmwZFd93z+/c869fbv77cvMG82ieaN9QUKDJAQFSAQQMiQBYiGgYpYyGCqYLY\
      4dJ6lyEbvKpsp/hLgAxywmLLKBGAxENluBJDbtEkhiJJgZSbPPm3n7e/26+y7n/PLHvb3MyJV\
      +dev2vX1f9/me3/e3fc+RBx5bAcAaWN+CTtfywOPCsydhtKnUa3Lj2iY3Hz2lt3Zz2d/taq6K\
      WhSLIoBRLQ/AUL4XFKODa9N7rv/50PX531Hdf953CJLEREmNR2Z3uu+PjspPi65/2FnYPJkzt\
      y/imtfW6awFei/H0CsEiCNoNiAotx04zH9Zb+nNW23AQGyVZgJGAhLKH7bVIKQ/2AEA2x9wwC\
      B94NIbsFL+/9AkoGAI2N4kAFYDRsrfaK8G2rneunIsv7XegJFRuXfvVbWPOSc/QHneqw9QFcZ\
      GYH0T+8AT/M8Dh/UDIUBSg/ExcAYICuFcS5nzLCHK0D3OteyQdW11T877ntKyDP1Gda2KqNJs\
      CBYggO96Nk6HW55p+Vts4BN7ro0/7GJRVRApcZlaDLUY5mag02X2Lz7LvT95VD/QTGBqHGq1c\
      ua0UMQrVssZtdqznvZn3GjAojgtD6OhOobeDz07+Ez7z9j+oec9F7CAeAUfsCGQxDA+YRAf2D\
      iTf/Dwz9r3tNfCTHPaIlYwTpDv3ruKSMmMj3/J/Pinj/Gyqy6qjOV7NAQhDGZW/yUqDnzG9qk\
      4/Oyw1c/33QFdhf+Pr57PCg2IgjWKNbDybMauq2s/venfj99sI1ENir3u5f+VrY7w118zn3rk\
      gPz2FReBDyVlLQMr2QqIRfu+ZVGcVJ9XNLJ9n+Oc/3HV/1kd+K4d8kNb+Z6p7jsBK71nFEfv+\
      /Uc9ljAhPJ7xqYMiwe6F7bPFrNzl0Tf6a55TLMOC0vccnxB/sOFO5TgQUJJsT5NGNDIVgNyKJ\
      oH8q7S3gi0Nz2RrQYAFSB/DpCeJQbXg0nsgYyNkrYKtlZy8paHovyt4YA2ADcMNiBFYGa3Y+N\
      o9v71k/nNUWJwcaT85FH5WDeDmQklFL3IVs2o0qeUk5J6ebeMovUaK7Ua989fET9p0NMHnsjS\
      RoJ7Hg37Ayv9WTgnUMkQhSXb9MXl1zWiyLFr8bn0mrQVbvQdP2kEoppgRJFwrmsYpR+sXCzkq\
      ef4z7c+ds1bxl/qikL3Hz5ub5oaqYJI/8c4x2+sQCiUrBsYqXP4gu32czPT9svHTxSn9lwYEV\
      nlkYdT6omgZbQvozOD60EU16H7Wp3L626qzO2t0RwzdFsFc3viXZ21/B3rJ9N3Z5vFvnpisK6\
      M1nYo2krlNuIDjTFh87nuS4qtkRe5p56R1/k8MDqh4BkK1wOntqaMoj4NbJ8yH5+ash+t1c1m\
      PYZxm5NuGDoeRm2gFuSclPAvpRM5L+AMJ3qxgWw1h7Zgu576dHTCZ/YvxrdHn/It+dOtM/mHb\
      SJEkQDheQWGUSVKhHQzsPRk5zZ38Fm5pWFL+oVz8lZJJ2fAZ7C+4rn5ZfG7U28/v7wGcdpi+/\
      aIrKnUrJIFg1OtWSX0krfV5+U5OZ9S5wP0GmxkSI2GUI+F8RGhfaYgimQ9nnAf2TFfO/DrH65\
      +xk05oliQQjFCP8gJYKV0h9bx7JWu1Qo3jCRU1tMhn1OcCKFQyDyX7TPvcI34yyxvMnJqBTca\
      oWY6KdS/5ddPdt8YAnuTRGODhoqLEgBBEEC1oqJyDoH7VUZ1v1Y39uiv2qkxenR03H4rBP2a6\
      RTtm94yy5EDHdpns89efMMIZ57a+ozBYO2gCOinFQ9xAmGzuEFuesPKWYvOolJFpjJURxqIJL\
      C+mHLJxdEnmtuaH5psFOxoL/DLh9swNXmLGvOJ1mpxdcgDzkCjbvrOVsICUaF3VVqOvnUH+XI\
      wsU4gbxdooUROqDflqaQuH3zDf9t9d3M64qdfOItBWfn11qcWn2q9f3xbBGEAcBA7AkZ10e65\
      7I//wKIjkXpqmpNoTt1n1CWj2OiwbSR/7qaXNl5vRfW6C7tsLaccOy3v7m4U/yid7raxuGAkK\
      mhYT6QFsebUKIi1oFZdx+qJ1OOoqpSeHw7lRFcNyhkI3YDxAfGB7nIxm67l74zrZnnXtSMPRQ\
      42j3WY3lv7QetE+q58Ix+Pa9IvMHopw4pgg266RFNiLUqLaYHTgNMCFwKkKVdeO/I3Y031e2Z\
      Sts1YDj5ubs5Xtj43u80RWVBfJnYAg1SxUBAFEFCh9xcQBAOhH4aqZwVRJXLQXc1J6mZ9++WN\
      LxkIm6fSt2+cSqce/sLCJ9Ll/KkrXjNx9/Z9CVknFDuubH76xM/X/tz2fLrv31VRIIq84fXPn\
      o60mIu0wKon0oCTgKYFNRvWX33H3EXGynIzCiCmcc/fH3+6s9LdMzLmwIc+vahCNpxHTxEQg6\
      igoYSPWIwYfBBQQ8CCCPmWEtfM0kvfOv3aLOWxIgvMXBBd+sidC3evHGrvnNpdO/7i3527UqC\
      lnUDwOvvknaeeodDROBJEwzlR2qoumEbo0ghdGprR1C517dDULnarxbZJf3/opMuuyMjWuxx9\
      5Mxb84XVPdMjBbW8TT10qYeURLskdEk0rY4udU1JSInSNlF7C11ZJ85a1EMXljcwWy2itE2iK\
      Q3K54vVDpfd1Pz6i98285hupWRn23RX84NTc9GdjRFLupTtPvnQxlu6awXqA77jF0em3f1hK8\
      eaXh3MoMJRxTVDp6QmpZ8YArEGyLbYvav5ROICdTzT83WOP3Dq9oZvU/cxoqXZykK8CixVm2K\
      sIdvKoYBGM9owkfvxthdNPLl6Ij3ZXs38Ra+a3r54aOvyfKt4ZWe9OweWaDShqRkuZLEK1PM2\
      pAW+FaO5RlZKn0yXsttnXzfzt5vHOsSRMHVh/YmN37RuNSEM8vdQ2nF1TYm06IO06okIQJfR2\
      J+YnY04/YszLD1x2oSV9T0TjZy4F5arCkIqdzNSkjNbSRkdiVemr576lB0b+fzxJzePbLtqiq\
      3WGhtrge3XTrF6qmD75cmUZPlbzz658eGNM2uXTozXOH3/2Tc//Gn7ZRO7e5MZSzTqrt881n1\
      7ZCEaEbKVbM/hu87YZMz5nftH2TwqJyIBE0rLcU53A65RWTBSj9MCi8cSGJtWjv/0ufzZHz1L\
      ojkuFLFrRHa8JhCyPs/pFQWABig2UqbnRv7v6EVTHwqjY0cbtcDeyU3k9Fmaq8s4mxOO1JnOl\
      qjbuRU71/zrfRPxF1cPrf3l4q823u/TbPTwN499b3z3yFcRW6yfWnubb2mjMRYhwVNs5Pbkz9\
      LYSeic/OcFTGzy5oxD/JAFBz6Iq2u3Hz0jLbAEHAXOB8SEqHBK3RXEEoKSevHn9n70yiQR8s0\
      uo7ONf4h2jNyBsyQby7i1FWZn6ljJqWetZs0GE4dsczzJ0CPHSOZnWGdya/v+md83nezk0lMb\
      f2691loHs3cGLMY4RkdrhKLoaUfBjjo13uOygFgiE4bHNKjEDIprhG6Vo0qaWg1lvsJjjEIsx\
      Jrh1KPKUDWv5XtArCE722Jy1/jP4vmZO9opXPPb+1j75v2cXWvZlqv9XnrkxBuyVrFPwSw+fP\
      KEieK7neOTzRFWx6YDS2dzdt684y9Gp+wFJ3589vcbc2NoKKufUPSm0aFqQcp8GdcsCiohnCd\
      c6aDU7OVBS4FTXx4EDAW2qvIrgIIiohWwULU+AqFV4GKfbt9/wbu6JuHCG3ez4/o5Fv+pPt86\
      /MwXzdn2yzUPRPUaiCE/sXUx1t3S9fKOsYsn/+PuFyb/pN0NtoJj9vptf7j84OnXsd6aj0brh\
      KBAKFOJBgIO1PR7SoVzi/XzrvsU7VnRaKhAekzV1sSalxYcki7oSwpCtr7OxP69Xxqbn3hmpm\
      5pNgsOf/LufWs/eerRJMonoriAmkE1QzEkowYVT7peXLzwjSfuSur2tvFLxr/vj2yQb9ruzhf\
      PfOzsfQufcWpRNSUoDKoOrcoF1CBqz0nww4KWVLqQq2uGCzlRZUGDx2lF0T7ADEdJ0d4XlhVm\
      WYhHI8Lcq678gp2oQ1aQntlg5a6HP8vJ5Ymxi7fju+lAV1NBq4FHUzGdM23OfvvJO+2/vvwSG\
      3Rt5hWXYl95wdc6h5Y/1l3enI7GGvjgQR2gBA2IEVBXQWHQflXU7HcxKC4JXSLysjzDlz6oHi\
      seowOAFl992UBQAiF02sRzkwebl+14QCLLxj2Pky6svc6tLv+r8V0NtLuF0x64cmqClKJhyAp\
      Gpx2dM+sz6dGlD02/fP7Pus+coXOmu9EYlx/4M+nbIokIagkEVAOKAy1VsqBx6URDGs35YrGr\
      0SUKRRk58X2KWi0qC5oBwMqCIlUetJY83aQxNfdk68ePBVevkUwmpL88+2+irI2TCA0QBgJIB\
      dQOzt4TbA5rG7dZo39WbLZp7BpHW+NPd58+i/Mxoa+jl3+iEFBUIxQVsM9X+npFfBKqRE9Zix\
      pCPx8aVHo+aIcpWlUx4oVozCELp0775TNkXQ/GQV5c2piM0NAdEEeFwBAwMXgtewk7adGF5R2\
      Ln75nhHqjZaanKTa6i8mYgZBVPhgIvd+VgKrgKYCgqgFwfSHqHAsmmlYpwmOrIFNG1ND3wai0\
      oADS6996RbVmbcx03dmpUXyrC9YRVjby0E7BRqhIFSgMQQz9VQ012HI6Cd6jRoNJ4iATEW7fJ\
      PnRJVOcXsM0haCKljYrFZygKDmGAvClFqGAmoGOW3bWuJqmff8ro2hZyViKQZAhO8eC/QBjLK\
      G7QdSc2xPtmsLM78LMzdL+xg8fT+97/LWyYzsU4KWsdUpfqvJZqXGjAtlyi/oL9h6dfNct7ez\
      kOqEwdLvJju6jbWwzIlS+V6oCWokAFtUcCGhfEYjKenhI3nIxWRlkCNgqH/aoagnDFuwVZP3Z\
      EQ/UgDOnr6m9/fWJNOvd7Okj1Oa3f4NfyH/WbAuNIkyogktF0XLAhiC2EgAy6nunvm5QJC8on\
      l0l/83p6yLrESkQQl9/074qZwiUAKFs21Sp6Dy0+FILGU5zHKXfuR5V8RgZULRXyfQoqtVqj8\
      RKWDm7iyd+9RrdNnNXvP9KpNF4SA4d/nz+44d/l4vmCaEoaSq+ChgBFUOIG2THTuPqjceSy3d\
      +RhfXqG0bIZ6s7+rc//SrogTQnKC2r+CoVn00FtWib0GtoEo/E/YWX8iI+0dKRFq+15TYp9R8\
      SkSGNTnWZZiowMQeG5dnaYChTfjhj95tp5sY6wlbKe7qyz4S7576hT11DFd0cCbHaU5EhpMCG\
      3Lk5AmSbc2V8dtf/jtmvFnI2AjR7CidB37zHhaWkqhhcCHDkg8dBZYcd949ISASEIpzFFgTa5\
      ealiBirY6QEmtGZDIiSTF1DyMaaBJoKowoNBVGFW0GZOcIrJ/8t7qy/HLRHNtaQNNs087P3xJ\
      fuutvo9D1bmMZV2xhQxe7uYLLt3DN6Pv1m1+4f+qj73q6Vg/wwKNkDxzYlf/8yT+KRyNsyCsw\
      RcWwXklZYLQAPIJHxGOkwFBgxGPEDyjqyMoUETyR5hg82ABRpdUrkABR5XfCoLOt8iEuRqhL8\
      e2vfl5+uft6MxWt27HdhPFow1y6/z1mZeUz4bkTbwqtzguDig3Ts7+R2W3fETfyXb+0TvYP36\
      F48ElYbtO979f/W7bajWj7DD7PUdyQ0lPWxgbF4/ASEA1o5YclYFOCruKpizUnCiV9xAWIpVw\
      WrQmQK7mHxEKtUlp6zV+/hQdCDjvGkLX1izl+6B5tXHab2R2dNdeMIRoTloqHZH7nQ3JyFelm\
      2PmdhHZObVsdPXKM/MtfR3fPS3F65essLr463jaL5l2kar2pho8O+WDIkayLOMS4UtwqK+WSp\
      iJl5WRqPiOSHGKFBmhDoaFQB6K8wHURu4WwYagVlibQCEizfF7qijQCxDmyrQkjeh3Lp36ki0\
      u3STKONgqITyLjHcSlwBY26RJPFMSzTaLRCN227QX+qcPf4/TCv3PTTUwoc5ypKGkoysrKBAi\
      5DeubJrTbaJ6Bz3MjodLshg+PEHDW5lDTMtzHikRlD6hbi9hXvrZmrroefe4xtLuRcfJZT2ul\
      t+w7lG9K2Q8PUm/AxvrV4Vc/+a6sXvJ/5IL5r4D8gGbcltkM61cx0TyaS6JZ8WJ/dOGtrLbfI\
      1ups2OTgCeEymJVxRsANULRbmOnp3yyf08m46NEN15G5/4j0eq3DmFnJlAtKooKgkXwOE1AEp\
      A4QFz5Wg3EFyDdnbTOwO4Lke27AnffeUzbR6+iGdMv45Fy90IoC2BCATMNJC3QxUN36NKxO7D\
      151A5QKt9DLU+LJ7dwZnVq8P9v7ycjQxTqyOTI3if01tf761fhB5MMWirS3TJBcdG3vjCIjuy\
      ij++grbTnaI5Ih4RKS2nPT+0OJIAiZYUjStwsZQ15dqRa5jfgzhBlw7D9qlvsKy/JU1KxbfCJ\
      Cpl+aSAFygKcIIkI5AGyLJ5PXtwHmlAEqPHngbTgMQhUQOXCkWRYcURKqtplb5N5fSBgDGeaK\
      bxj8WhU5jxCTCKP76y3xhFjCKhBCVV8BE8TmqUFI0HNCUuoF5Hi6WX0ExmsHZJ6nVk8savhrU\
      D/13bS7tkZAKC78cbFMRLaclCoAAtKJd6YkFqE2gKpIrsmIJugA5oGtAANlO8lOo4QBBTVjDq\
      kShGF9dxM5Mnazdd9PeIUIhBamGuWFy/yYw4CAVC1PfBitgYapUFE0WSgCQBkgCjDnRtTBd+8\
      V5Mu4yUydSWbL/wHehKGW2bCdQjSBzULTQEGgEavgxEjVBeJwq1Aql5JFGIcojL+1LTMg25gA\
      lVLsP3g4yxoO0tdG2N2ov2vcvMjLV8Rwln1+jc+/R7dHmzYROLqK9sHgZJXwJGerTsWTIB6oo\
      kiowIYeXJ96Jtx9ZzsPkcTO29x1z8it8rVQQPSR3qDaglkMRlAEos1BUSj9RCFcR0MJG967gK\
      bHGZa8X0op+vqhJFN9ZhZZWR973+I6P/6U0/JM8pDp9Cuh2XP33yvRJLCaRvuR5QreSVWI1Jg\
      FooQSXlmaSAqQkIWxfq2QMfV9tFu79Gdl6JzL/mc0zsulkm556QmgHnIRKkPgL1egk6qYA2FK\
      lXlku07w7Sc4vevQqwmACdFmysQ7eNGW/8Jr5676212278q7DZIX/oKZzLSB889MmwtL7bTta\
      GQJ1nQQ3GhXocO7NOkSSDma0FiC1ENaQ2h6ZLH5C18CDT2+8kOw5pB3z4iVx40426efzNkm68\
      EQ3z2l6toTZQWKFwYKxgczC5YBQx/XVOKoGlTNCFlsGpBqS5s9unU7G142Zi6ltcdPFX04cPt\
      fyvDuGXNwnL6/hWeJ8/svA+Oz2ChjKg0AdVBhzaOWasFrswPnJIOqdvkKQ+BM5BVIM4QuIINQ\
      btnvqS6AXg1+/UWhuZ3wdJPWWTO+22q+8MviA888NYTC2IqqhWlVwQIFRlUH8lA6rag0r36b9\
      vd5x52ZUptab3z51CrGI76+iR48iOC9D1rfelDz77NzIzg4kE78vI2W+bRDEmULQLzC572HVm\
      993XOPXUDcQBYg+RHQIXQ+QgipHRPUK68GU1Y9cytv1PGJnsYgS2jaCuDq0VZLSZIUmZJooCc\
      gdZAbkp/VWgElQH5Z4OnT2QaEavarEFFF3sVBNVnSweO/in+SMHP+hmJ9HYUhRFf+UxVHVx2d\
      0r5J7ostH7XGfi0rt0yXzY2i1CXIc4Li1YiyGKy+2HkYO4BgaU7h/SXXy9WPNZ6vaLYtyKjk5\
      C5BGdBEYgy5EiR7MMyXLopmiaQp4iaadKEQaNKVNIFFAnYA2ykWF2ToAmhFoEeXGhen17/oMH\
      3x1axV47O0kwBvUFIlJ281X7GyoLhrRABKILGne5kPt7u+O7n27IkSuCm4AoKoFFUQkuHgIZR\
      YgdBSmuICz/D+22/ghxP5fO6QOkWycILkd9De/Be+kfwQshCF4Nvt/lDJqA4aNWL8IzRyJyt1\
      uPnt7vDxy5IbT9qDE1mBotC4EQ6O2s6UXLfsVjFF1q416w46C5ZuJeZ2vBtyZv+JPGysGvSww\
      aVWBcVFoydkhcgY4dOAe2XtZT6neg/nZNj94OBpqTkHV75SkSFLyWUdYH8J5yW4SvViqr7U9W\
      BjuPxhuEXzwKG4pqjCSjmEYTT1TuDlRbypY9KjKwoBolFB5WUuLb931Ubt1eOL/7Ijbdi74RH\
      1v99sT6996QN68DZ5HIVtasjloF0tihOGEpN6mUM0oIYBKQtBKGqggXfPmZ9+AjcAU4LdsyR/\
      k+AiKBzMPEKMSCyS0hlGsSEMpJ6/VMlQ/3rBjKvWbwxDLxm1/wXXvr7q/qUopL911PiJsszF3\
      0ttrPTz9a7xy6Im9ei0YOcRW4Hk3FgAhSqWSliFjpIFqpUE7KAfT2Y4YAhQfvEWtRa8HZEuSQ\
      BcWA9rYomgDGoN6XN6ukXza3Wl5XKrZqQC3lnuzHFpAb9h60/+uVd9Bw6FIHI1kHt7WMEDqnL\
      //jN3br1xyOus+WBbaLS0pGEVRyO2JQsSAWNRaMAXEV+GplzjmIHOIqSjsD1qDGlM8b09vG26\
      em9je4lPkSKVeupJ9YtM8cGW62I4MEj3n8FHLjBcfsX736TQRt6XLpKuU2aTGYfAM17uDxiz/\
      6orWxW//OpQtELCIxqItQKpBiyrNxiLGIcSVtjUGkPJAKpK0mwFjE2DJKDoEUOwApPbC95ry3\
      P7on1zNYNsBZiCySZphnF5FDK+hbr/umfuX2/RLbp1jpln7NOZvSBZev0x3ZtrE58dLfybq7/\
      rlhT/1BIyxcH+kSaupoNIqGUrTF2N5cVvWjojKkKRgLppToxRhUpFwVqraV9DUd019LoTflMl\
      AgKr8bWFDyDLPYRjYVHZ2keMVlT/hr930iXLXjc1J3cGgFxiYHohNDLxWD8V3ifIGt5tVfadV\
      e8pXxzv2vwSbvqMvJ34qKzJuIIK43SFdGsxD6G35U+vPVH2z5vtLE+7yrJqT3eA8Ug3N5URYG\
      Wvl1iBumuHzK5Ndd9qOQ8nfFO1/yHTa9l/uOoDfsLH1x6PX/AIOpxUa1uuHgAAAAAElFTkSuQ\
      mCC');
    background-size: 1.1em !important;
  }

  .trix-button--icon-vaults::before {
    background-image: url('data:image/svg+xml;base64,PHN2ZyBhcmlhLWhpZGRlbj0idH\
      J1ZSIgZm9jdXNhYmxlPSJmYWxzZSIgZGF0YS1wcmVmaXg9ImZhciIgZGF0YS1pY29uPSJhcmN\
      oaXZlIiByb2xlPSJpbWciIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgdmll\
      d0JveD0iMCAwIDUxMiA1MTIiIGNsYXNzPSJzdmctaW5saW5lLS1mYSBmYS1hcmNoaXZlIGZhL\
      XctMTYgZmEtMngiPjxwYXRoIGZpbGw9ImN1cnJlbnRDb2xvciIgZD0iTTQ2NCAzMkg0OEMyMS\
      41IDMyIDAgNTMuNSAwIDgwdjgwYzAgOC44IDcuMiAxNiAxNiAxNmgxNnYyNzJjMCAxNy43IDE\
      0LjMgMzIgMzIgMzJoMzg0YzE3LjcgMCAzMi0xNC4zIDMyLTMyVjE3NmgxNmM4LjggMCAxNi03\
      LjIgMTYtMTZWODBjMC0yNi41LTIxLjUtNDgtNDgtNDh6bS0zMiA0MDBIODBWMTc2aDM1MnYyN\
      TZ6bTMyLTMwNEg0OFY4MGg0MTZ2NDh6TTIwNCAyNzJoMTA0YzYuNiAwIDEyLTUuNCAxMi0xMn\
      YtMjRjMC02LjYtNS40LTEyLTEyLTEySDIwNGMtNi42IDAtMTIgNS40LTEyIDEydjI0YzAgNi4\
      2IDUuNCAxMiAxMiAxMnoiIGNsYXNzPSIiPjwvcGF0aD48L3N2Zz4=');
    background-size: 1.1em !important;
  }

  .trix-button--icon-vaults.trix-active {
    background: none !important;
  }
  trix-toolbar .trix-button-group--text-tools .trix-button--icon-underline {
    text-indent: 0;
    text-decoration: underline;
  }

  .trix-button-group--file-tools {
    position: relative;
  }

  .image-tooltip {
    line-height: 28px;
    color: #bf0000;
    position: absolute;
    left: 50%;
    transform: translateX(-50%);
    top: -30px;
  }

  .image-tooltip-source {
    display: inline-block;
    position: absolute;
    top: 24px;

    &.attach {
      left: 0;
    }

    &.facebook {
      left: 25%;
    }

    &.link {
      left: 25%;
    }

    &.instagram {
      left: 50%;
    }

    &.vault {
      left: 75%;
    }
  }
</style>
