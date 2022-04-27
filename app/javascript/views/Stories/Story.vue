<template>
  <div class="story-viewer pt-10">
    <v-container 
      v-if="story.id" 
      id="intro-stories-view-story">
      <v-row no-gutters>
        <v-col cols="12" md="4" lg="3" class="mt-2 pr-md-12">
          <div class="story-left-sidebar d-flex flex-column align-center">
            <StoryAvatar class="mb-4" />
            <Tooltip
              position="right"
              name="commentLike"
              :icons="['mdi-forum-outline', 'mdi-heart-outline']"
              :title="$i18n.t('tooltips.comment_like_title')"
              :description="$i18n.t('tooltips.comment_like_description')"
            >
              <template #activator="{ attrs }">
                <div
                  v-bind="attrs"
                  class="d-flex flex-column align-items-center mb-9 mx-auto"
                >
                  <StoryLikes class="mb-4" />
                  <StoryCommentsButton />
                </div>
              </template>
            </Tooltip>
            <TableOfContents
                :add-chapter-enabled="canCollaborateStory"
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
            :share-type="story.publication.attributes.shareType"
          />
          <StoryChapterLoader />
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'

import StoryAvatar from '@/components/Story/StoryAvatar'
import StoryDescription from '@/components/Story/StoryDescription'
import StoryChapterLoader from '@/components/Story/StoryChapterLoader'
import StoryChapter from '@/components/Story/StoryChapter'
import TableOfContents from '@/components/Elements/Chapters/TableOfContents'
import StoryLikes from '@/components/Story/StoryLikes'
import StoryCommentsButton from '@/components/Story/StoryCommentsButton'
import Tooltip from '@/components/Elements/Tooltip.vue'
import { storiesShowCaseConfig, storiesShowCaseData } from '@/plugins/showcaseStaticData'
import { delay } from '@/utils/functions'

export default {
  components: {
    StoryAvatar,
    StoryDescription,
    StoryChapter,
    TableOfContents,
    StoryChapterLoader,
    StoryLikes,
    StoryCommentsButton,
    Tooltip
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
    },
    canCollaborateStory() {
      return this.$possible('collaborate', 'Publication', {
            shareType: this.story.publication.attributes.shareType,
            familyId: this.story.publication.attributes.familyId,
            story: { userId: this.story.userId }
          })
    }
  },
  watch: {
    activeChapter(chapterId) {
      if (chapterId) {
        this.goToSelectedChapter(chapterId)
        this.setStoryActiveChapter(chapterId)
      }
    }
  },
  created () {
    this.fetchStory()
  },
  async mounted() {
    this.$vuetify.goTo(document.body, 0)

    if(localStorage.getItem('fromMyLifeTourStep')){
      await delay(1000)
      this.showTour()

       localStorage.removeItem('fromMyLifeTourStep')
    }
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
        await this.getChapters({id: this.story.publication.id})
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`story-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({behavior: 'smooth', block: 'center'})
      }
    },
    showTour() {
      this.$driver
        .init(storiesShowCaseConfig(this))
        .defineSteps(storiesShowCaseData(this.$driver, this))
        .start(this.$driver.instance.steps.length - 1)
    },
    fetchStory () {
      this.clearChapters()
      this.getPublication({
        id: this.publicationId,
        options: {
          include: 'families,user',
          ...this.getShowcaseOptions()
        }
      })
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour') ||
        localStorage.getItem('fromStoryTourStep')) {
        result.showcase = true
      }

      return result
    },
  }
}
</script>

<style lang="scss" scoped>
.story-left-sidebar {
  position: sticky;
  top: 176px;
  height: calc(100vh - 280px);
}
</style>
