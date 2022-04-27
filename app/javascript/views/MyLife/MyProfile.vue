<template>
  <div
    class="profile"
    v-if="member.id"
  >
    <MyProfileHeader />
    <v-container class="mt-10">
      <v-row>
        <v-col
          cols="12"
          md="4"
          lg="3"
          class="mt-2 mb-md-4 pr-md-12"
        >
          <div class="left-sidebar d-flex flex-column align-center">
            <template v-if="editing">
              <MemberAvatarEdit class="mb-8" />
            </template>
            <template v-else>
              <Avatar
                class="mb-8"
                size="biggest"
                :src="member.avatarUrl"
              />
            </template>
            <MemberTableOfContents
              v-if="!isMobile"
              data-type="member"
              :is-edit-mode="editing"
              :add-chapter-enabled="tourIsEnabled"
            />
          </div>
        </v-col>
        <v-col
          cols="12"
          md="8"
          lg="9"
        >
          <template v-if="editing">
            <div
              class="profile__name-label mb-2"
              v-text="$i18n.t('placeholders.family.name')"
            />
            <v-text-field
              class="profile__name-input"
              :value="nickname"
              outlined
              hide-details
              single-line
              color="tertiary"
              type="text"
              large
              @change="(value) => handleEdit({ nickname: value })"
            />
          </template>
          <template v-else>
            <h1 class="profile__name">{{ member.nickname }}</h1>
          </template>

          <div class="d-flex align-center my-6">
            <span
              class="d-flex align-center"
              id="intro-my-life-switch-profiles"
            >
              <span class="profile__select-label mr-3">Profile:</span>
              <SelectMyProfileCommunity
                :key="`SelectMyProfileCommunity-${key}`"
                :preselect="selected"
                @selected="selectedCommunity"
              />
            </span>
          </div>

          <ProfileContactDetails
            class="mb-6"
            :key="`profile-${member.id}-${profileAttrChecksum}`"
            :attributes="member.profile"
            :kinship-id="member.id"
            :editable="editing"
          />

          <RecentStoriesCarousel
            :key="member.community.id"
            class="mb-6"
            v-if="member.community && member.community.id && member.userId"
            :community-id="member.community.id"
            :community="member.community"
            :author-id="member.userId"
          />

          <template v-if="editing">
            <div
              v-for="(chapter, index) in sortedChapters"
              :key="chapter.id"
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
          </template>

          <template v-else>
            <MemberChapter
              class="mb-6"
              v-for="chapter in sortedChapters"
              :key="`chapter-${chapter.id}`"
              :ref="`member-chapter-${chapter.id}`"
              :chapter="chapter"
            />
          </template>
        </v-col>
      </v-row>
    </v-container>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import { debounce } from 'lodash'

import MemberTableOfContents from '../../components/Elements/Chapters/TableOfContents'
import Avatar from '../../components/Elements/Avatar'
import RecentStoriesCarousel from '../../components/Community/RecentStoriesCarousel'
import MemberChapter from '../../components/Member/MemberChapter'
import MyProfileHeader from '../../components/Toolbars/MyProfileHeader'
import SelectMyProfileCommunity from '../../components/Toolbars/MyLife/SelectMyProfileCommunity'
import MemberAvatarEdit from '../../components/Member/MemberAvatarEdit'
import MemberChapterEdit from '../../components/Member/MemberChapterEdit'
import AddChapter from '../../components/Elements/Chapters/AddChapter'

import breakpointsMixin from '../../mixins/breakpointsMixin'
import keyMixin from '@/mixins/keyMixin'
import profileAttributesMixin from '@/views/MyLife/mixins/profileAttributesMixin'
import EventBus from '@/plugins/event-bus'
import { myLifeShowCaseConfig, myLifeShowCaseData } from '@/plugins/showcaseStaticData'
import { delay } from '@/utils/functions'

export default {
  components: {
    Avatar,
    MemberTableOfContents,
    RecentStoriesCarousel,
    MemberChapter,
    MyProfileHeader,
    SelectMyProfileCommunity,
    MemberAvatarEdit,
    MemberChapterEdit,
    AddChapter
  },
  mixins: [breakpointsMixin, profileAttributesMixin, keyMixin],
  beforeRouteLeave(to, from, next) {
    this.clearChapters()
    this.clearMember()

    next()
  },
  data: () => ({
    form: {},
    selected: null
  }),
  computed: {
    ...mapState({
      currentUser: (state) => state.core.user,
      chosenFamilyId: (state) => state.core.user.familyId,
      member: (store) => store.members.member,
      activeChapter: (store) => store.members.activeChapter,
      chapters: (store) => store.members.chapters,
      families: (state) => state.core.user.personalPrivateFamilies
        .concat(state.families.simpleList.families),
    }),
    sortedChapters() {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    },
    editing() {
      return (
        this.$possible('manage', 'Kinship', {
          userId: this.member.userId, familyId: this.member.familyId, accessType: this.member.accessType
        }) &&
        this.$route.query.editing === 'true'
      )
    },
    nickname() {
      return this.form?.nickname ?? this.member.nickname
    },
    profileAttrChecksum() {
      return JSON.stringify(this.member.profile)
    },
    tourIsEnabled(){
      return !!localStorage.getItem('tour')
    }
  },
  watch: {
    chosenFamilyId(communityId) {
      if (!this.selected) this.getMyProfile(communityId)
    },
    families: {
      handler: 'setDefaultFamily',
      immediate: true
    }
  },
  async created() {
    this.selected = this.$route.query?.community

    EventBus.$on('updated:profile', () => {
      this.selectedCommunity(this.selected)
    })

    if (this.selected) await this.getMyProfile(this.selected)
    else if (this.chosenFamilyId) await this.getMyProfile(this.chosenFamilyId)

    this.getChapters(this.getShowcaseOptions())
  },
  async mounted() {
    
    if (localStorage.getItem('tour') && !localStorage.getItem('fromPreviousTourStep')) {      
      await delay(500)
  
      this.showTour(1)

      await this.loadFamilies( this.getShowcaseOptions(), { root: true })

      // preselect specific family
      const johnsFamily = this.families.find(el => {
        return el.attributes.name.toLowerCase().includes('jones family adventures')
      })
      this.selected = johnsFamily.id
      this.keyPlus()
    }else if(localStorage.getItem('fromPreviousTourStep')){
      // preselect specific family
      const johnsFamily = this.families.find(el => {
        return el.attributes.name.toLowerCase().includes('jones family adventures')
      })
      this.selected = johnsFamily.id
      this.keyPlus()
    }
  },
  methods: {
    ...mapActions({
      clearMember: 'members/clearMember',
      clearChapters: 'members/clearChapters',
      getChapters: 'members/getChapters',
      setActiveChapter: 'members/setActiveChapter',
      updateMember: 'members/updateMember',
      loadFamilies: 'families/loadQuickList'
    }),
    showTour(stepNumber = 0) {
      this.$driver
        .init(myLifeShowCaseConfig(this))
        .defineSteps(myLifeShowCaseData(this.$driver, this))
        .start(stepNumber)
    },
    async selectedCommunity(communityId) {
      this.selected = communityId
      await this.getMyProfile(communityId)
      await this.getChapters(this.getShowcaseOptions())
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
      result.showcase = true
      }

      return result
    },
    async submit() {
      const payload = {
        id: this.member.id,
        form: this.form
      }

      await this.updateMember(payload)
    },
    handleEdit: debounce(function (attributes) {
      this.form = {
        ...attributes
      }
      this.submit(attributes)
    }),
    setDefaultFamily() {
      if (!this.families || !this.families.length || this.selected) { return }

      this.selectedCommunity(this.families[0].id)
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
.profile {
  &__name {
    color: $color-tertiary;
    font-size: 40px;

    &-label {
      color: $color-tertiary;
      font-family: Enriqueta;
      font-size: 18px;
      font-weight: bold;
      line-height: 24px;
    }

    &-input {
      &.v-text-field {
        font-size: 18px;
        color: $tertiary;
        .v-input__control {
          min-height: 48px !important;
        }
        .v-input__slot {
          min-height: 48px !important;
        }
        .v-label {
          top: 6px !important;
        }
        &--outlined fieldset {
          border-color: $medium-grey;
        }
      }
    }
  }

  &__select-label {
    color: $color-grey;
    font-size: 18px;
    font-weight: bold;
  }
}
</style>
