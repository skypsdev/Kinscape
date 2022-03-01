<template>
  <div class="story-viewer pt-10">
    <v-container v-if="story.id">
      <v-row no-gutters>
        <v-col cols="12" md="4" lg="3" class="mt-2 pr-md-12">
          <div class="story-left-sidebar d-flex flex-column align-center">
            <StoryAvatar class="mb-4" />
            <StoryLikes class="mb-4" />
            <StoryCommentsButton class="mb-9" />
            <TableOfContents
                add-chapter-enabled
                data-type="story"
            />
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <StoryDescription />
          <v-divider class="my-12" />
          <StoryChapter
            v-for="chapter in sortedChapters"
            :key="chapter.id"
            :ref="`story-chapter-${chapter.id}`"
            :chapter="chapter"
          />
          <StoryChapterLoader />
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'

import StoryAvatar from '../../components/Story/StoryAvatar'
import StoryDescription from '../../components/Story/StoryDescription'
import StoryChapterLoader from '../../components/Story/StoryChapterLoader'
import StoryChapter from '../../components/Story/StoryChapter'
import TableOfContents from '../../components/Elements/Chapters/TableOfContents'
import StoryLikes from '../../components/Story/StoryLikes'
import StoryCommentsButton from '../../components/Story/StoryCommentsButton'

export default {
  components: {
    StoryAvatar,
    StoryDescription,
    StoryChapter,
    TableOfContents,
    StoryChapterLoader,
    StoryLikes,
    StoryCommentsButton
  },
  computed: {
    ...mapState({
      story: store => store.stories.story,
      activeChapter: store => store.stories.activeChapter,
      chapters: store => store.sections.all
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
      clearChapters: 'sections/clearSections',
      updateChapterList: 'stories/updateChapterList',
      setStoryActiveChapter: 'stories/setStoryActiveChapter'
    }),
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        await this.getChapters(this.story.id)
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`story-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({behavior: 'smooth', block: 'center'})
      }
    },
    fetchStory () {
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
</script>

<style lang="scss" scoped>
.story-left-sidebar {
  position: sticky;
  height: calc(100vh - 176px);
}
</style>
