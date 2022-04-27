import { SectionsRepository, StoriesRepository } from '../repositories'
import { mapActions } from 'vuex'

export const sectionsMixin = {
  methods: {
    ...mapActions({
      updateChapterList: 'stories/updateChapterList'
    }),
    chapterList () {
      try {
        StoriesRepository.listTableOfContents(
          this.story.publication.id
        ).then(response => {
          this.updateChapterList(response.data.attributes.links)
        })
      } catch (error) {
        console.log(error)
      }
    },
    createSection: async function (story, position, sections) {
      var isLastSection = false
      if (sections.length > 0 && position === sections.length) {
        isLastSection = true
        this.sectionLoader(position, sections)
      }
      const params = {
        position: position,
        title: this.$i18n.t('sections.title_placeholder'),
        rich_body: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
      }
      this.$emit('update:savingStatus', 'started')
      try {
        const response =
          await SectionsRepository.createSection(story.publication.id, params)
        this.$emit('success')
        this.$emit('update:storyChanged', true)
        this.$emit('update:savingStatus', 'finished')
        if (isLastSection) {
          this.sectionCreated(response.data, sections)
        } else {
          if (this.sortedSections === undefined) {
            this.$emit('sectionCreated', response.data)
          } else {
            location.reload()
          }
        }
      } catch (error) {
        console.error(error)
        this.$emit('failure')
        this.$emit('update:savingStatus', 'failed')
      }
    },
    saveSection: function (section) {
      this.$store.dispatch('queueSectionUpdate')
      if (this.timeout) clearTimeout(this.timeout)
      this.timeout = setTimeout(async () => {
        this.$emit('update:savingStatus', 'started')
        try {
          await SectionsRepository.updateSection(
            this.story.publication.id, section.id, section.attributes
          )
          this.chapterList()

          this.$emit('success')
          this.$emit('update:storyChanged', true)
          this.$emit('update:savingStatus', 'finished')
          this.$store.dispatch('unqueueSectionUpdate')
        } catch (error) {
          console.error(error)
          this.$emit('failure')
          this.$emit('update:savingStatus', 'failed')
          this.$store.dispatch('unqueueSectionUpdate')
        }
      }, 500)
    },
    elementSelector (index) {
      return '.content-wrapper .section:nth-child(' + (index + 1) + ')'
    },
    sectionLoader (position, sections) {
      const sectionLoader = {
        id: 0,
        loader: true,
        attributes: { position: position }
      }
      sections.splice(position, 0, sectionLoader)
    },
    sectionCreated (section, sections, isLastSection = true) {
      const length = isLastSection ? 1 : 0

      sections.splice(section.attributes.position, length, section)
      sections.forEach((s, i) => { s.attributes.position = i })

      const selector = this.elementSelector(section.attributes.position)
      while (!document.querySelector(selector)) {
        this.loadSections(this.storyId)
      }
      this.$scrollTo(selector, 500, { offset: -80 })
    }
  }
}
