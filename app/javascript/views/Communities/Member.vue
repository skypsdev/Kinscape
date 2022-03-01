<template>
  <div>
    <v-container v-if="member" class="mt-10">
      <v-row>
        <v-col cols="12" md="4" lg="3" class="mt-2 mb-md-4 pr-md-12">
          <div class="left-sidebar d-flex flex-column align-center">
            <Avatar class="mb-8" size="biggest" :src="member.avatarUrl" />
            <MemberTableOfContents
              v-if="!isMobile"
              :add-chapter-enabled="isCurrentUser"
              data-type="member"
            />
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <ProfileDetails />
          <RecentStoriesCarousel
            v-if="member.community && member.userId"
            :community-id="member.community.id"
            :community="member.community"
            :author-id="member.userId"
          />
          <MemberChapter
            v-for="chapter in sortedChapters"
            :key="chapter.id"
            :ref="`member-chapter-${chapter.id}`"
            :chapter="chapter"
          />
        </v-col>
      </v-row>
    </v-container>
    <section v-if="!member">
      <div class="message-container">
        <div class="inner">
          <p class="message">
            You're not a member of any Community. My Life profiles are meant to
            be shared with Communities. Click Add Community to create your first
            Community or ask another Community member on Kinscape to invite you.
          </p>
          <a href="/communities/new">Add Community</a>
        </div>
      </div>
    </section>
  </div>
</template>

<script>
import { mapState, mapActions } from 'vuex'

import ProfileDetails from '../../components/Member/ProfileDetails'
import MemberTableOfContents from '../../components/Elements/Chapters/TableOfContents'
import Avatar from "../../components/Elements/Avatar";
import breakpointsMixin from "../../mixins/breakpointsMixin";
import RecentStoriesCarousel from "../../components/Community/RecentStoriesCarousel";
import MemberChapter from "../../components/Member/MemberChapter";

export default {
  components: {
    RecentStoriesCarousel,
    Avatar,
    ProfileDetails,
    MemberTableOfContents,
    MemberChapter,
  },
  mixins: [
    breakpointsMixin
  ],
  computed: {
    ...mapState({
      currentUser: store => store.core.user,
      member: store => store.members.member,
      activeChapter: store => store.members.activeChapter,
      chapters: store => store.members.chapters
    }),
    memberId() {
      return this.$route.params.id.toString()
    },
    isCurrentUser() {
      return this.member?.userId?.toString() === this.currentUser.id?.toString()
    },
    familyId() {
      return this.member.familyId
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
        this.setActiveChapter()
      }
    }
  },
  async mounted () {
    await this.getMember({
      id: this.memberId,
      options: {
        include: 'family'
      }
    })
    await this.getChapters()
  },
  destroyed() {
    this.clearMember()
  },
  methods: {
    ...mapActions({
      getMember: 'members/getMember',
      clearMember: 'members/clearMember',
      getChapters: 'members/getChapters',
      setActiveChapter: 'members/setActiveChapter'
    }),
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        await this.getChapters()
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`member-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({behavior: 'smooth', block: 'center'})
      }
    },
  }
}
</script>
<style lang="scss" scoped>
.left-sidebar {
  position: fixed;
  height: calc(100vh - 176px);
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    height: initial;
  }
}
</style>
