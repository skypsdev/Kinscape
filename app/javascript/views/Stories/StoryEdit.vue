<template>
  <div class="story-editor pt-10">
    <v-container v-if="story.id">
      <v-row no-gutters>
        <v-col cols="12" md="4" lg="3" class="mt-2 mb-4 pr-md-12">
          <div class="story-left-sidebar d-flex flex-column align-center">
            <StoryAvatarEdit class="mb-4" />
            <StoryLikes disabled class="mb-4" />
            <StoryCommentsButton disabled class="mb-9" />
            <TableOfContents
                data-type="story"
                is-edit-mode
            />
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <StoryDescriptionEdit v-if="story.canCollaborateStory" :key="story.id" />
          <StoryDescription v-else />
          <v-divider class="my-12" />
          <div
            v-for="(chapter, index) in sortedChapters"
            :key="chapter.id"
            :ref="`story-chapter-${chapter.id}`"
          >
            <AddChapter
              class="mb-10"
              separator
              :position="index"
              view-type="story"
              :edit-mode="true"
            />
            <StoryChapterEdit
              v-if="chapter.attributes.is_author"
              class="mb-16"
              :chapter="chapter"
            />
            <StoryChapter
              v-else
              :chapter="chapter"
            />
          </div>
          <AddChapter
            class="mb-12"
            separator
            :position="story.content.links.length"
            view-type="story"
            :edit-mode="true"
          />
          <StoryChapterLoader />
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import {mapActions, mapGetters, mapState} from 'vuex'

import StoryChapterEdit from '../../components/Story/StoryChapterEdit'
import StoryChapter from '../../components/Story/StoryChapter'
import StoryAvatarEdit from '../../components/Story/StoryAvatarEdit'
import StoryChapterLoader from '../../components/Story/StoryChapterLoader'
import StoryDescriptionEdit from '../../components/Story/StoryDescriptionEdit'
import StoryDescription from '../../components/Story/StoryDescription'
import TableOfContents from '../../components/Elements/Chapters/TableOfContents'
import StoryLikes from '../../components/Story/StoryLikes'
import StoryCommentsButton from '../../components/Story/StoryCommentsButton'
import AddChapter from "../../components/Elements/Chapters/AddChapter";

export default {
  components: {
    StoryChapter,
    AddChapter,
    StoryChapterEdit,
    StoryChapterLoader,
    StoryDescription,
    StoryDescriptionEdit,
    TableOfContents,
    StoryLikes,
    StoryCommentsButton,
    StoryAvatarEdit
  },
  computed: {
    ...mapState({
      story: store => store.stories.story,
      activeChapter: store => store.stories.activeChapter,
      chapters: store => store.sections.all
    }),
    ...mapGetters({
      hasMorePages: 'sections/hasMorePages'
    }),
    publicationId () {
      return this.$route.params.id
    },
    sortedChapters () {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    }
  },
  watch: {
    activeChapter(chapterId) {
      if (chapterId) {
        this.goToSelectedChapter(chapterId)
        this.setStoryActiveChapter()
      }
    }
  },
  mounted () {
    this.fetchStory()
  },
  methods: {
    ...mapActions({
      getPublication: 'stories/getPublication',
      getChapters: 'sections/loadNext',
      getChaptersAgain: 'sections/loadCurrentPage',
      clearChapters: 'sections/clearSections',
      setStoryActiveChapter: 'stories/setStoryActiveChapter'
    }),
    async goToSelectedChapter(chapterId) {
      const selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        if (this.hasMorePages) {
          await this.getChapters(this.story.id)
        } else {
          await this.getChaptersAgain(this.story.id)
        }
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`story-chapter-${chapterId}`]
        if (chapter) {
          chapter[0].scrollIntoView({behavior: 'smooth', block: 'center'})
          const input = chapter[0].querySelector('input:not([type=hidden])')
          if (input) input.focus()
        }
      }
    },
    fetchStory () {
      if (this.story.publication.id !== this.$route.params.id) {
        this.clearChapters()
        this.getPublication({
          id: this.publicationId,
          options: {
            include: 'families,user'
          }
        })
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.story-left-sidebar {
  position: sticky;
  height: calc(100vh - 176px);
}
</style>
