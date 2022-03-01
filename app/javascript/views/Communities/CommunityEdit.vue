<template>
  <div class="community-editor pt-10">
    <v-container v-if="community.id">
      <v-row no-gutters>
        <v-col cols="12" md="4" lg="3" class="mt-2 mb-4 pr-md-12">
          <div class="community-left-sidebar d-flex flex-column align-center">
            <CommunityAvatarEdit class="mb-8" />
            <CommunityTableOfContents
                is-edit-mode
                data-type="community"
            />
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <CommunityDescriptionEdit :key="community.id" />
          <v-divider class="my-12" />
          <div
              v-for="(chapter, index) in sortedChapters"
              :key="chapter.id"
              :class="`community-chapter-${chapter.id}`"
              :ref="`community-chapter-${chapter.id}`"
          >
            <AddChapter
                class="mb-10"
                separator
                :position="index"
                view-type="community"
                :edit-mode="true"
            />
            <CommunityChapterEdit
                class="mb-16"
                :chapter="chapter"
            />
          </div>
          <AddChapter
              v-if="sortedChapters.length"
              class="mb-12"
              separator
              :position="community.content.links.length"
              view-type="community"
              :edit-mode="true"
          />
          <EmptyState v-if="!isMobile && !sortedChapters.length" />
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'

import CommunityAvatarEdit from '../../components/Community/CommunityAvatarEdit'
import CommunityTableOfContents from '../../components/Elements/Chapters/TableOfContents'
import CommunityDescriptionEdit from "../../components/Community/CommunityDescriptionEdit";
import CommunityChapterEdit from "../../components/Community/CommunityChapterEdit";
import EmptyState from "../../components/Community/EmptyState";
import breakpointsMixin from "../../mixins/breakpointsMixin";
import AddChapter from "../../components/Elements/Chapters/AddChapter";

export default {
  components: {
    EmptyState,
    CommunityChapterEdit,
    CommunityDescriptionEdit,
    AddChapter,
    CommunityTableOfContents,
    CommunityAvatarEdit
  },
  mixins: [breakpointsMixin],
  computed: {
    ...mapState({
      community: store => store.families.community,
      activeChapter: store => store.families.activeChapter,
      chapters: store => store.families.chapters,
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
        this.setCommunityActiveChapter()
      }
    }
  },
  mounted () {
    this.fetchFamily()
    this.getChapters(this.familyId)
  },
  methods: {
    ...mapActions({
      getFamily: 'families/getCommunity',
      getChapters: 'families/getChapters',
      setCommunityActiveChapter: 'families/setCommunityActiveChapter'
    }),
    async goToSelectedChapter(chapterId) {
      await this.$nextTick()
      const chapter = this.$refs[`community-chapter-${chapterId}`]
      if (chapter) {
        chapter[0].scrollIntoView({behavior: 'smooth', block: 'center'})
        const input = chapter[0].querySelector('input:not([type=hidden])')
        if (input) input.focus()
      }
    },
    fetchFamily () {
      this.getFamily({
        id: this.familyId,
        options: {}
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.community-left-sidebar {
  position: sticky;
  height: calc(100vh - 176px);
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    top: 0;
    height: 450px;
  }
}
</style>
