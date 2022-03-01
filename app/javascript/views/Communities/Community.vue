<template>
  <v-container class="mt-10">
    <v-row>
      <v-col cols="12" md="4" lg="3" class="mt-2 mb-md-4 pr-md-12">
        <div class="community-left-sidebar d-flex flex-column align-center">
          <CommunityAvatar class="mb-8" />
          <CommunityTableOfContents
              v-if="!isMobile"
              add-chapter-enabled
              data-type="community"
          />
        </div>
      </v-col>
      <v-col cols="12" md="8" lg="9">
        <CommunityDescription/>
        <RecentStoriesCarousel :community-id="familyId"/>
        <CommunityChapter
            v-for="chapter in sortedChapters"
            :key="chapter.id"
            :ref="`community-chapter-${chapter.id}`"
            :chapter="chapter"
        />
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
import RecentStoriesCarousel from "../../components/Community/RecentStoriesCarousel";
import breakpointsMixin from "../../mixins/breakpointsMixin";

export default {
  components: {
    CommunityAvatar,
    CommunityChapter,
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
    familyId () {
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
    this.getFamily({
      id: this.familyId,
      options: {}
    })
    this.getChapters(this.familyId)
  },
  methods: {
    ...mapActions({
      getFamily: 'families/getCommunity',
      getChapters: 'families/getChapters',
      setStoryActiveChapter: 'families/setCommunityActiveChapter'
    }),
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        await this.getChapters(this.familyId)
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`community-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({behavior: 'smooth', block: 'center'})
      }
    },
  }
}
</script>
<style lang="scss" scoped>
.community-left-sidebar {
  position: fixed;
  height: calc(100vh - 176px);
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    height: initial;
  }
}
</style>
