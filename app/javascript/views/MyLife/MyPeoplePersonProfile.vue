<template>
  <v-container v-if="member" class="mt-10">
    <v-row>
      <v-col cols="12" md="4" lg="3" class="mt-2 mb-md-4 pr-md-12">
        <div class="left-sidebar d-flex flex-column align-center mx-auto">
          <Avatar class="mb-8" size="biggest" :src="member.avatarUrl" />
          <Tooltip
            v-if="!isCurrentUser && isActiveUser"
            position="bottom right"
            name="startConversation"
            :icons="['mdi-email-outline']"
            :title="$i18n.t('tooltips.start_conversation_title')"
            :description="$i18n.t('tooltips.start_conversation_description')"
          >
            <template #activator="{ attrs }">
              <v-btn
                v-bind="attrs"
                class="w--100"
                :fab="isMobile"
                :small="isMobile"
                rounded
                outlined
                color="#8B78FE"
                elevation="0"
                :title="$i18n.t('header.message_title')"
                @click="openConversationDialog"
              >
                <v-icon :left="!isMobile">mdi-email-outline</v-icon>
                <span v-if="!isMobile">
                  {{ $i18n.t("header.message_title") }}
                </span>
              </v-btn>
            </template>
          </Tooltip>
          <TableOfContents
            v-if="!isMobile && links.length"
            :set-active-chapter="setChapter"
            :active-chapter="activeChapter"
            :links="links"
          />
        </div>
      </v-col>
      <v-col cols="12" md="8" lg="9">
        <ProfileContactDetails
          class="mb-6"
          :key="`profile-${member.id}`"
          :attributes="member.profile"
          :kinship-id="member.id"
        />

        <RecentStoriesCarousel
          v-if="$$(member, 'community', 'id')"
          :community-id="member.community.id"
          :community="member.community"
          :author-id="member.userId"
        >
          <router-link
            tag="h2"
            :to="{
              name: 'stories',
              query: {
                familyId: member.familyId,
              },
            }"
            class="stories-carousel__title secondary--text"
          >
            Life Stories
          </router-link>
        </RecentStoriesCarousel>

        <MemberChapter
          v-for="chapter in sortedChapters"
          :key="chapter.id"
          :ref="`member-chapter-${chapter.id}`"
          :chapter="chapter"
        />
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'
import { sortBy as _sortBy } from 'lodash'

import TableOfContents from '@/components/MyPeople/TableOfContents'
import Avatar from "@/components/Elements/Avatar"
import RecentStoriesCarousel from "@/components/Community/RecentStoriesCarousel"
import MemberChapter from "@/components/Member/MemberChapter"
import Tooltip from '@/components/Elements/Tooltip.vue'

import profileAttributesMixin from '@/views/MyLife/mixins/profileAttributesMixin'
import breakpointsMixin from "@/mixins/breakpointsMixin"

import { smoothScroll } from '@/utils/functions'
export default {
  name: "MyPeopleProfile",
  components: {
    RecentStoriesCarousel,
    Avatar,
    TableOfContents,
    MemberChapter,
    Tooltip
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
      member: store => store.myPeoplePerson.member.member,
    }),
    ...mapState('myPeoplePerson/chapters', ['chapters', 'activeChapter']),
    ...mapGetters('myPeoplePerson/chapters', ['links']),
    sortedChapters() {
      return _sortBy(this.chapters, ['position'])
    },
    memberId() {
      return this.$route.params.id || null
    },
    isCurrentUser() {
      return this.member?.userId?.toString() === this.currentUser.id?.toString()
    },
    isActiveUser() {
      return Boolean(this.member.userId)
    }
  },
  watch: {
    activeChapter(chapterId) {
      if (chapterId) {
        this.goToSelectedChapter(chapterId)
      }
    }
  },
  created() {
    this.loadData(this.memberId)
  },
  mounted() {
    this.$vuetify.goTo(document.body, 0)
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    ...mapActions('myPeoplePerson', ['loadData']),
    ...mapActions('myPeoplePerson/chapters', ['setActiveChapter', 'clearChapters']),
    ...mapActions('myPeoplePerson/member', ['clearMember']),
    setChapter(id) {
      if (this.activeChapter != id) {
        this.setActiveChapter(id)
      }
    },
    async goToSelectedChapter(chapterId) {
      let selectedChapter = this.chapters.find((chapter) => chapter.id === chapterId)
      if (selectedChapter) {

        await this.$nextTick()
        const chapter = this.$refs[`member-chapter-${chapterId}`]
        if (chapter) smoothScroll(chapter[0].$el)
      }
    },
    openConversationDialog() {
      this.setDialog({
        component: 'SendMessageToMembersDialog',
        title: this.$i18n.t('requests.title'),
        data: {
          kinshipsIds: [this.member.id.toString()],
          familyId: this.member.community.id,
          locked: true
        }
      })
    }
  }
}
</script>
<style lang="scss" scoped>
.left-sidebar {
  position: sticky;
  height: auto;
  top: 176px;
  max-width: 208px;
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    height: initial;
  }
}
</style>
