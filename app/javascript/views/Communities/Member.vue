<template>
  <div class="w--100">
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
            <v-btn
              v-if="!isCurrentUser && isActiveUser"
              class="ml-1"
              :fab="isMobile"
              :small="isMobile"
              rounded
              outlined
              color="primary"
              elevation="0"
              :title="$i18n.t('header.message_title')"
              @click="openConversationDialog"
            >
              <v-icon :left="!isMobile">mdi-email-outline</v-icon>
              <span v-if="!isMobile">
                {{ $i18n.t("header.message_title") }}
              </span>
            </v-btn>
          </div>
        </v-col>
        <v-col cols="12" md="8" lg="9">
          <h1 class="profile__name">{{ member.nickname || member.name }}</h1>

          <h3 class="profile-member__title mt-3 mb-8">
            {{
              $i18n.t("users.profile_page.edit_member_title", {
                communityName: member.community.name
              })
            }}
            {{
              $i18n.t(`families.member_roles.${member.role}`)
            }}

          </h3>
          <div v-if="isEmptyDetails" class="left-sidebar d-flex flex-column align-center pt-5">
            <p> {{ $i18n.t("families.members_empty_title") }} </p>

            {{ $i18n.t("families.members_empty_message", { name: member.nickname || member.name }) }}
            <v-btn
              class="ml-1 mt-3"
              :fab="isMobile"
              :small="isMobile"
              rounded
              color="primary"
              elevation="0"
              :title="$i18n.t('header.message_title')"
              @click="openConversationDialog"
            >
              <v-icon :left="!isMobile">mdi-email-outline</v-icon>
              <span v-if="!isMobile">
                {{ $i18n.t("header.message_title") }}
              </span>
            </v-btn>
          </div>
          <ProfileDetails
            v-if="hasValidProfileValues(member.profile)"
            class="mb-6"
            :key="`profile-${memberId}`"
            :kinship-id="memberId"
            :attributes="member.profile"
          />

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
      <div>
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

import ProfileDetails from '@/components/Profiles/ProfileContactDetails.vue'
import MemberTableOfContents from '@/components/Elements/Chapters/TableOfContents'
import Avatar from "@/components/Elements/Avatar"
import RecentStoriesCarousel from "@/components/Community/RecentStoriesCarousel"
import MemberChapter from "@/components/Member/MemberChapter"

import breakpointsMixin from "@/mixins/breakpointsMixin"
import profileAttributesMixin from '@/views/MyLife/mixins/profileAttributesMixin'

export default {
  components: {
    RecentStoriesCarousel,
    Avatar,
    ProfileDetails,
    MemberTableOfContents,
    MemberChapter,
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
      chapters: store => store.members.chapters,
      loading: store => store.members.loading
    }),
    memberId() {
      return this.$route.params.id
    },
    isCurrentUser() {
      return this.member?.userId?.toString() === this.currentUser.id?.toString()
    },
    familyId() {
      return this.member.familyId
    },
    sortedChapters() {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    },
    isActiveUser() {
      return !!this.member.userId
    },
    isEmptyDetails() {
      return (!this.loading && !this.isCurrentUser && this.isActiveUser && !(this.hasValidProfileValues(this.member.profile) || this.sortedChapters.length))
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
  async created() {
    await this.getMember({
      id: this.memberId,
      options: {
        include: 'family'
      }
    })
    this.getChapters()
  },
  mounted() {
    this.$vuetify.goTo(document.body, 0)
  },
  methods: {
    ...mapActions({
      getMember: 'members/getMember',
      clearMember: 'members/clearMember',
      clearChapters: 'members/clearChapters',
      getChapters: 'members/getChapters',
      setActiveChapter: 'members/setActiveChapter',
      setDialog: 'layout/setDialog'
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
  @media #{map-get($display-breakpoints, 'sm-and-down')} {
    position: relative;
    height: initial;
  }
}
</style>
