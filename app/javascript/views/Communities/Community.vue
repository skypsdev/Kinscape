<template>
  <v-container
    class="mt-10"
    id="intro-communities-community-profile-2"
  >
    <v-row>
      <v-col
        cols="12"
        md="4"
        lg="3"
        class="mt-2 mb-md-4 pr-md-12"
      >
        <div class="community-left-sidebar d-flex flex-column align-center">
          <CommunityAvatar class="mb-8" />
          <CommunityTableOfContents
            v-if="!isMobile"
            :add-chapter-enabled="canManageCommunity"
            data-type="community"
          />
        </div>
      </v-col>
      <v-col
        cols="12"
        md="8"
        lg="9"
      >
        <CommunityDescription />
        <RecentStoriesCarousel :community-id="familyId" />
        <CommunityChapter
          v-for="chapter in sortedChapters"
          :key="chapter.id"
          :ref="`community-chapter-${chapter.id}`"
          :chapter="chapter"
        />
        <EmptyState class="pt-16" v-if="!isMobile && !sortedChapters.length" />
      </v-col>
    </v-row>
  </v-container>
</template>
<script>
import { mapActions, mapState } from 'vuex'
import CommunityAvatar from "../../components/Community/CommunityAvatar";
import CommunityDescription from "../../components/Community/CommunityDescription";
import CommunityTableOfContents from "../../components/Elements/Chapters/TableOfContents";
import CommunityChapter from "../../components/Community/CommunityChapter";
import EmptyState from "../../components/Community/EmptyState";
import RecentStoriesCarousel from "../../components/Community/RecentStoriesCarousel";
import breakpointsMixin from "../../mixins/breakpointsMixin";
import { communitiesShowCaseConfig, communitiesShowCaseData } from '@/plugins/showcaseStaticData';
import { delay } from '@/utils/functions';

export default {
  components: {
    CommunityAvatar,
    CommunityChapter,
    EmptyState,
    CommunityDescription,
    CommunityTableOfContents,
    RecentStoriesCarousel
  },
  mixins: [
    breakpointsMixin
  ],
  computed: {
    ...mapState({
      community: state => state.families.community,
      activeChapter: store => store.families.activeChapter,
      chapters: store => store.families.chapters
    }),
    familyId() {
      return this.$route.params.id
    },
    sortedChapters() {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    },
    canManageCommunity() {
      return this.$possible('manage', 'Family', { id: this.community.id })
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
  created() {
    this.getFamily({
      id: this.familyId,
      options: this.getShowcaseOptions()
    })
    this.getChapters({
      id: this.familyId,
      options: this.getShowcaseOptions()
    })

    // this.$eventBus.on('show-community-tour',()=>{
    //   this.showTour()
    // })
  },
 async mounted() {
    this.$vuetify.goTo(document.body, 0)

    if(localStorage.getItem('fromStoryTourStep')){
      await delay(1000)
       this.showTour()

       localStorage.removeItem('fromStoryTourStep')
    }
  },
  methods: {
    ...mapActions({
      getFamily: 'families/getCommunity',
      getChapters: 'families/getChapters',
      setStoryActiveChapter: 'families/setCommunityActiveChapter'
    }),
    showTour() {
      this.$driver
        .init(communitiesShowCaseConfig(this))
        .defineSteps(communitiesShowCaseData(this.$driver, this))
        .start(this.$driver.instance.steps.length - 1)
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour') ||
        localStorage.getItem('fromStoryTourStep')) {
        result.showcase = true
      }

      return result
    },
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        await this.getChapters({ id: this.familyId })
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`community-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    },
  }
}
</script>
<style lang="scss" scoped>
.community-left-sidebar {
  position: sticky;
  height: auto;
  top: 176px;
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    height: initial;
  }
}
</style>
