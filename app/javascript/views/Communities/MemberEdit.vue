<template>
  <div>
    <v-container v-if="member" class="mt-10">
      <v-row>
        <v-col cols="12" md="4" lg="3" class="mt-2 mb-md-4 pr-md-12">
          <div class="left-sidebar d-flex flex-column align-center">
            <MemberAvatarEdit class="mb-8" />
            <MemberTableOfContents
              v-if="!isMobile"
              is-edit-mode
              data-type="member"
            />
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <div class="my-life main-profile-div">
            <ProfileDetailsEdit :key="`details-edit-${member.id}`">
              <ProfileContactDetails
                class="mb-6"
                :key="`profile-${member.id}`"
                :kinship-id="member.id"
                :attributes="member.profile"
                editable
              />
            </ProfileDetailsEdit>
            <div
              v-for="(chapter, index) in sortedChapters"
              :key="`chapters-${chapter.id}`"
              :ref="`member-chapter-${chapter.id}`"
            >
              <AddChapter
                class="mb-10"
                separator
                :position="index"
                view-type="member"
                :edit-mode="true"
              />
              <MemberChapterEdit
                :ref="`member-chapter-${chapter.id}`"
                class="mb-16"
                :chapter="chapter"
              />
            </div>
            <AddChapter
              class="mb-12"
              separator
              :position="member.content.links.length"
              view-type="member"
              :edit-mode="true"
            />
          </div>
        </v-col>
      </v-row>
    </v-container>
    <section v-if="!member">
      <div>
        <div class="inner">
          <p class="message">
            {{ $i18n.t("communities.members.edit.no_member_found") }}
          </p>
          <a href="/communities/new">
            {{ $i18n.t("communities.members.edit.create_new_community") }}
          </a>
        </div>
      </div>
    </section>
  </div>
</template>
<script>
import { mapState, mapActions } from 'vuex'

import ProfileDetailsEdit from '../../components/Member/ProfileDetailsEdit'
import MemberTableOfContents from '../../components/Elements/Chapters/TableOfContents'
import MemberAvatarEdit from "../../components/Member/MemberAvatarEdit"
import MemberChapterEdit from "../../components/Member/MemberChapterEdit"
import AddChapter from "../../components/Elements/Chapters/AddChapter"

import breakpointsMixin from "../../mixins/breakpointsMixin"
import profileAttributesMixin from '@/views/MyLife/mixins/profileAttributesMixin'

export default {
  components: {
    MemberAvatarEdit,
    ProfileDetailsEdit,
    MemberTableOfContents,
    MemberChapterEdit,
    AddChapter,
  },
  mixins: [
    breakpointsMixin,
    profileAttributesMixin
  ],
  beforeRouteLeave(to, from, next) {
    this.clearChapters()
    this.clearMember()

    next()
  },
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
    sortedChapters() {
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
  async mounted() {
    this.$vuetify.goTo(document.body, 0)
    
    await this.getMember({
      id: this.memberId,
      options: {
        include: 'family'
      }
    })
    this.getChapters()
  },
  methods: {
    ...mapActions({
      getMember: 'members/getMember',
      getChapters: 'members/getChapters',
      setActiveChapter: 'members/setActiveChapter',
      clearMember: 'members/clearMember',
      clearChapters: 'members/clearChapters',
    }),
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (!selectedChapter) {
        await this.getChapters()
        await this.goToSelectedChapter(chapterId)
      } else {
        await this.$nextTick()
        const chapter = this.$refs[`member-chapter-${chapterId}`]
        if (chapter) chapter[0].$el.scrollIntoView({ behavior: 'smooth', block: 'center' })
      }
    },
  }
}
</script>
<style lang="scss" scoped>
.left-sidebar {
  position: sticky;
  height: calc(100vh - 176px);
}
</style>
