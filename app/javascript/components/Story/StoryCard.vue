<template>
  <v-hover v-slot="{ hover }">
    <v-card
      elevation="0"
      :class="{ 'story-card--active': hover }"
      class="story-card mx-auto"
      :to="{
          name: 'showStory',
          params: { id: story.publication.id }
        }"
    >
      <v-img
        :src="story.attributes.coverUrl || require('../../assets/images/story-blank.png')"
        height="203px"
        class="story-card__image"
      >
        <div
          v-if="storyCardLabel"
          class="story-card__label"
          v-text="storyCardLabel"
        />

        <div class="story-card__chips">
          <v-chip
              v-if="!isCommunityProfile"
              class="story-card__chip story-card__chip--community"
              :class="{'story-card__chip--community--disabled' : !isPrivate}"
              @click.prevent.stop="goToCommunity"
          >
            {{ communityName }}
          </v-chip>
          <div
            v-if="!isPrivate|| isCommunityProfile"
            class="d-flex flex-column">
            <v-chip
              class="story-card__chip story-card__chip--comments"
              @click.prevent.stop="goToComments"
            >
              {{ commentsCount}}
              <v-icon right small>mdi-forum-outline</v-icon>
            </v-chip>

            <v-chip
              class="story-card__chip story-card__chip--appreciations"
              :class="{'story-card__chip--active': appreciations.id}"
              @click.prevent.stop="handleAppreciate"
            >
              {{ appreciations.count }}
              <v-icon right small>{{appreciations.id ?'mdi-heart' : 'mdi-heart-outline'}}</v-icon>
            </v-chip>
          </div>
        </div>
        <div
          v-if="hover"
          class="story-card__meta"
        >
          <template>
            <span v-text="$i18n.t('stories.chapters', { count: story.attributes.sectionsCount })" />
            <span v-if="!isPrivate" v-text="$i18n.t('stories.contributors', { count: story.attributes.contributorsCount })" />
            <span v-text="$i18n.t('stories.created_at', { time: $i18n.l('date.formats.default', story.attributes.createdAt) })" />
            <span v-text="$i18n.t('stories.last_updated_at', { time: $i18n.l('date.formats.default', story.attributes.updatedAt) })" />
            <span
              v-if="story.attributes.isTimeCapsule"
              v-text="$i18n.t('stories.time_capsule.release_on', { date: $i18n.l('date.formats.default', story.attributes.publishOn) })"
            />
            <span v-text="story.attributes.dateAsText" />
          </template>
        </div>

      </v-img>
      <v-card-title class="story-card__title">
        <Avatar
          class="story-card__avatar"
          :src="story.publication.attributes.userAvatar"
        />
        <span
          class="story-title"
          :data-story-id="story.publication.id"
          v-text="story.attributes.title"
        />
      </v-card-title>
    </v-card >
  </v-hover>
</template>

<script>
import Avatar from '../Elements/Avatar'
import {AppreciationsRepository} from "../../repositories";
import {mapActions} from "vuex";

export default {
  components: {
    Avatar
  },
  props: {
    story: {
      type: Object,
      required: true
    },
    isCommunityProfile: {
      type: Boolean,
      default: false
    }
  },
  data: () => ({
    appreciations: {
      loading: false,
      count: 0,
      id: false
    }
  }),
  computed: {
    isPrivate() {
      return this.story.publication.attributes.shareType === 'private'
    },
    communityName () {
      return this.isPrivate ? this.$i18n.t('stories.private_stories') : this.story.community.attributes.name
    },
    storyCardLabel () {
      const label = this.story.isTimeCapsule ? 'stories.time_capsule.label' : 'stories.unread'
      return this.story.isTimeCapsule || this.story.attributes.unread ? this.$i18n.t(label) : ''
    },
    commentsCount() {
      return this.story.publication?.attributes?.allCommentsCount || 0
    }
  },
  mounted () {
    this.appreciations = {
      count: this.story.publication.attributes.appreciationsCount,
      id: this.story.publication.attributes.appreciationId
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      setError: 'layout/setError'
    }),
    handleAppreciate() {
      if (!this.appreciations.loading) {
        if (this.appreciations.id) {
          this.removeAppreciation()
        } else {
          this.createAppreciation()
        }
      }
    },
    removeAppreciation() {
      this.appreciations.loading = true
      AppreciationsRepository.deleteAppreciation(this.appreciations.id)
        .then(()=> {
          this.appreciations.count = this.appreciations.count -1
          this.appreciations.id = ''
        })
        .catch((error)=> {
          this.setError(error)
        })
        .finally(()=> {
          this.appreciations.loading = false
        })
    },
    createAppreciation() {
      this.appreciations.loading = true
      AppreciationsRepository.createAppreciation({
        reaction: 'smile',
        appreciableId: this.story.publication.id,
        appreciableType: 'Publication',
        publicationId: this.story.publication.id
      })
        .then((res)=> {
          this.appreciations.count = this.appreciations.count +1
          this.appreciations.id = res.data.id
        })
        .catch((error)=> {
          this.setError(error)
        })
        .finally(()=> {
          this.appreciations.loading = false
        })
    },
    goToCommunity() {
      if (!this.isPrivate) {
        this.$router.push({name: 'showFamily', params: {id: this.story.community.id}})
      }
    },
    goToComments() {
      this.$router.push({name: 'showStory', params: {id: this.story.publication.id}})
      this.setDialog({
        component: 'CommentsDialog',
        title: this.$i18n.t('stories.comments.story_comments'),
        data: {
          commentableId: this.story.publication.id,
          parentId: this.story.publication.id
        }
      })
    }
  }
}
</script>

<style lang="scss" scoped>
$block: ".story-card";
.story-card {
  border: 2px solid $color-light-grey;
  border-radius: 10px !important;
  height: 264px;
  width: 264px;
  overflow: hidden;
  &--active {
    border-color: #534898;
    #{$block}__image {
      background-color: #534898;
      border-radius: 0 !important;
    }
  }
  &__image {
    position: relative;
    background-color: $color-disabled;
    border-radius: 0 !important;
  }
  &__avatar {
    margin-right: 13px;
  }
  &__title {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: #4B4B4B;
    display: flex;
    span {
      flex: 1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }
  &__label {
    position: absolute;
    left: 0;
    top: 21px;
    z-index: 10;
    padding: 4px 12px;
    background: $color-primary;
    border-radius: 2px 10.5px 10.5px 2px;
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 16px;
    line-height: 21px;
    color: #FFFFFF;
  }
  &__chips {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 10;
    padding: 8px;
    display: flex;
    flex-direction: row;
    justify-content: flex-end;
    align-items: flex-end;
  }
  &__chip {
    height: 24px;
    margin: 4px;
    background: $color-lightest_purple !important;
    opacity: 1;
    &--community {
      font-family: Enriqueta;
      font-style: normal;
      font-weight: bold;
      font-size: 13px;
      line-height: 17px;
      color: #534898;
      margin-left: 0;
      margin-right: auto;
      &::v-deep .v-chip__content {
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
      }
      &:hover:not(.story-card__chip--community--private) {
        color: #534898;
        background-color: #C5BCFF !important;
      }
      &--private {
        color: $color-primary;
      }
      &--private:hover {
        background-color: #FCD0C4 !important;
      }
    }
    &--comments,
    &--appreciations {
      font-family: Lato;
      font-style: normal;
      font-weight: bold;
      font-size: 16px;
      line-height: 19px;
      color: #4B4B4B;
      &:hover {
        color: $color-primary;
        background-color: #FCD0C4 !important;
        .v-icon {
          color: $color-primary;
        }
      }
    }
    &--active {
      color: white !important;
      background-color: $color-primary !important;
      .v-icon {
        color: white;
      }
      &:hover {
        color: $color-primary !important;
        background-color: #FCD0C4 !important;
        .v-icon {
          color: $color-primary !important;
        }
      }
    }
  }
  &__meta {
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background: rgba(75, 75, 75, 0.8);
    color: white;
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 13px;
    line-height: 16px;
    display: flex;
    flex-direction: column;
    justify-content: flex-start;
    align-items: center;
    padding-top: 46px;
  }
}
</style>
