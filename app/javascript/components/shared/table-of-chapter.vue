<template>
  <div id="table-of-contents">
    <div
      class="table-of-contents-wrapper"
    >
      <h4>{{ $i18n.t("stories.table_of_sections.title") }}</h4>
      <ul :title="$i18n.t('stories.chapters.title')">
        <ChapterOfList
          v-if="tocLinks.length && typeObject === 'Family'"
          v-sortable="{ onUpdate: updateSectionPosition,
                        handle: '.reorder-section' }"
          :links="tocLinks"
          :is-edit-mode="isEditMode"
        />
        <ChapterOfListKinship
          v-if="tocLinks.length && typeObject === 'Kinship'"
          v-sortable="{ onUpdate: updateSectionPosition,
                        handle: '.reorder-section' }"
          :links="tocLinks"
          :is-edit-mode="isEditMode"
        />
      </ul>
    </div>
  </div>
</template>

<script>
import ChapterOfList from './chapter-of-list.vue'
import ChapterOfListKinship from './chapter-of-list-kinship.vue'
import FamilySectionsRepository from
  '../../repositories/family-sections-repository'

export default {
  components: { ChapterOfList, ChapterOfListKinship },
  props: {
    tocLinks: {
      type: Array,
      default: () => []
    },
    chapters: {
      type: Array,
      default: () => []
    },
    isEditMode: {
      type: Boolean,
      default: false
    },
    familyId: {
      type: [String, Number]
    },
    kinshipId: {
      type: [String, Number],
      default: 0
    },
    typeObject: {
      type: String
    }
  },
  methods: {
    async updateSectionPosition (event) {
      while (this.chapters.length < (event.oldIndex + 1)) {
        this.loadChapter()
      }
      const chapter = this.chapters[event.oldIndex]
      chapter.attributes.position = event.newIndex
      this.$emit('update:storyChanged', true)
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.chapters.splice(event.newIndex, 0,
        // TODO Fix mutating prop
        // eslint-disable-next-line vue/no-mutating-props
        this.chapters.splice(event.oldIndex, 1)[0])
      this.saveChapter(chapter)
    },

    saveChapter (chapter) {
      if (this.timeout) clearTimeout(this.timeout)
      var payload = this.paramsPayload(chapter.attributes)

      this.timeout = setTimeout(async () => {
        this.$emit('update:savingStatus', 'started')
        let id = chapter.id
        let att = payload
        try {
          await FamilySectionsRepository.updateChapter(id, att)
          this.$emit('update:savingStatus', 'finished')
        } catch (error) {
          this.$emit('update:savingStatus', 'failed')
          console.log(error)
        }
      }, 500)
    },
    loadChapter () {
      var payload = this.paramsPayload()
      try {
        FamilySectionsRepository.getSection(
          payload
        )
          .then(response => {
            // TODO Fix mutating prop
            // eslint-disable-next-line vue/no-mutating-props
            this.chapters = response.data
          })
      } catch (error) {
        console.error(error)
      }
    },
    paramsPayload (payload = {}) {
      payload.type = this.typeObject
      payload.familyId = this.familyId

      if (this.typeObject === 'Kinship') {
        payload.kinshipId = this.kinshipId
      }
      return payload
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
