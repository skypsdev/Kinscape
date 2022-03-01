<template>
  <div
    v-if="chapters.length"
    class="content-wrapper pt-0"
  >
    <div
      v-for="content in chapters"
      :key="content.id"
      class="chapter_data relative"
    >
      <AcceptRemoveChapter
        v-if="showDeletingMessage && content.id === selectedChapter.id"
        @cancelDelete="hideRemovePrompt()"
        @deleteChapter="deleteChapter(kinship)"
      />
      <div class="add-content-wrapper">
        <div class="add-content">
          <a
            class="add-chapter-btn add-btn"
            :title="$i18n.t('stories.chapters.new')"
            @click="onAddChapter(content.attributes.position)"
          >
            {{ $i18n.t('stories.chapters.new') }}
          </a>
        </div>
      </div>
      <div class="chapter-edit-container">
        <div
          v-if="!showDeletingMessage"
          class="edit-actions"
        >
          <a
            class="remove-section"
            title="Remove Content Area"
            @click="showRemovePrompt(content)"
          >
            <i class="fa fa-trash-o" />
          </a>
        </div>
        <input
          id="sectionTitle"
          :value="content.attributes.title ===
            $i18n.t('sections.title_placeholder')
            ? '' : content.attributes.title"
          :placeholder="(content.attributes.title ===
            $i18n.t('sections.title_placeholder') ||
            content.attributes.title === '')
            ? $i18n.t('sections.title_placeholder') : ''"
          type="text"
          class="inputField"
          @change="updateTitle($event, content)"
        >
        <RichEditor
          :input="'chapter_content_' + content.id"
          :current-user="currentUser"
          :value="chapterBody(content)"
          :class="{'disable-btn':
            !kinship.attributes.is_current_user_connector &&
            kinship.attributes.user_id != currentUser.id}"
          @editor-change="assignContentAndSave($event, content)"
        />
      </div>
    </div>
    <div class="add-content-wrapper">
      <div class="add-content add-content-bottom">
        <a
          class="add-chapter-btn add-btn"
          :title="$i18n.t('stories.chapters.new')"
          @click="onAddChapter(chapters.length)"
        >
          {{ $i18n.t('stories.chapters.new') }}
        </a>
      </div>
    </div>
  </div>
</template>

<script>
// TODO: refactoring required (move to vuex)

import RichEditor from './rich-editor'
import AcceptRemoveChapter from './AcceptRemoveChapter'
import FamilySectionsRepository
  from '../../repositories/family-sections-repository'
import { mapActions } from 'vuex'

export default {
  components: { RichEditor, AcceptRemoveChapter },
  props: {
    currentUser: {
      type: Object,
      required: true
    },
    kinship: {
      type: Object,
      required: true
    },
    chapters: {
      type: Array,
      default: () => []
    }
  },
  data () {
    return {
      selectedChapter: null,
      showDeletingMessage: false
    }
  },
  methods: {
    ...mapActions({
      updateChapterList: 'kinships/updateChapterList',
      getKinshipByFamily: 'kinships/getKinshipByFamily'
    }),
    async onAddChapter (position) {
      await this.createChapter(position)
      await this.chapterList()
    },
    chapterList () {
      const optionsData = {
        familyId: this.kinship.attributes.family_id,
        kinshipId: this.kinship.id,
        type: 'Kinship'
      }
      try {
        FamilySectionsRepository.listTableOfContents(optionsData)
          .then(response => {
            this.updateChapterList(response.data.attributes.links)
          })
      } catch (error) {
        console.log(error)
      }
    },
    createChapter: async function (position) {
      let isLastSection = false
      if (this.chapters.length > 0 && position === this.chapters.length) {
        isLastSection = true
        this.sectionLoader(position)
      }
      const params = {
        familyId: this.kinship.attributes.family_id,
        kinshipId: this.kinship.id,
        type: 'Kinship',
        media_type: 'text',
        position: position,
        title: this.$i18n.t('sections.title_placeholder'),
        rich_body: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
      }
      try {
        const response =
            await FamilySectionsRepository.createSection(params)
        if (isLastSection) {
          this.sectionCreated(response.data)
        } else {
          if (this.chapterLoader === undefined) {
            // this.$emit('sectionCreated', response.data)
          } else {
            this.sectionCreated(response.data, isLastSection)
          }
        }
      } catch (error) {
        console.error(error)
      }
    },
    sectionCreated (section, isLastSection = true) {
      let length = 0
      if (isLastSection) {
        length = 1
      }
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.chapters.splice(section.attributes.position, length, section)
      this.chapters.forEach((s, i) => { s.attributes.position = i })
      const selector = '.content-wrapper .chapter_data:nth-child(' +
          (section.attributes.position + 1) + ')'
      // while (!document.querySelector(selector)) {
      //   // TODO: Need to work on scroll
      //   this.loadSections(this.family.id)
      // }
      this.$scrollTo(selector, 500, { offset: -80 })
    },
    sectionLoader (position) {
      const sectionLoader = {
        id: 0,
        loader: true,
        attributes: { position: position }
      }
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.chapters.splice(position, 0, sectionLoader)
    },
    chapterBody (chapter) {
      return !chapter.attributes.rich_body ||
      chapter.attributes.rich_body.body ===
      '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
        ? '' : chapter.attributes.rich_body.body
    },
    updateTitle (event, content) {
      content.attributes.title = event.target.value
      this.assignContentAndSave('', content)
    },
    deleteChapter: async function () {
      try {
        await FamilySectionsRepository.deleteSection(
          this.selectedChapter.id,
          {
            familyId: this.kinship.attributes.family_id,
            kinshipId: this.kinship.id,
            type: 'Kinship'
          }
        ).then(() => {
          this.showDeletingMessage = false
          this.chapterList()
          this.getKinshipByFamily(this.kinship.attributes.family_id)
        })
      } catch (error) {
        console.error(error)
      }
    },
    hideRemovePrompt () {
      this.showDeletingMessage = false
    },
    showRemovePrompt (chapter) {
      this.selectedChapter = chapter
      this.showDeletingMessage = true
    },
    chapterLoader () {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    },
    assignContentAndSave (event, chapter) {
      if (event) {
        if (!Array.from(event.target.childNodes).map(node => {
          return node.localName
        }).includes('h1')) {
          let html = event.target.inputElement.value
          html = html.replace('<div><!--block--><br></div>', '')
          event.target.inputElement.value = html
        }
        if (chapter.attributes.rich_body.body ===
            event.target.inputElement.value) return
        chapter.attributes.rich_body.body = event.target.inputElement.value
      }
      chapter.attributes.title = (chapter.attributes.title === '')
        ? this.title : chapter.attributes.title

      this.$set(chapter, 'rich_body', chapter.attributes.rich_body)
      this.save(chapter)
    },
    save (chapter) {
      chapter.attributes.type = 'Kinship'
      chapter.attributes.familyId = this.kinship.attributes.family_id
      chapter.attributes.kinshipId = this.kinship.id

      if (this.timeout) clearTimeout(this.timeout)
      this.timeout = setTimeout(async () => {
        this.$emit('update:savingStatus', 'started')
        let id = chapter.id
        let att = chapter.attributes
        try {
          await FamilySectionsRepository.updateChapter(id, att)
          this.chapterList()
          this.$emit('update:savingStatus', 'finished')
        } catch (error) {
          this.$emit('update:savingStatus', 'failed')
          console.log(error)
        }
      }, 500)
    }

  }
}
</script>
