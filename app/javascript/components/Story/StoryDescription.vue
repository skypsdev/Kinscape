<template>
  <div class="story-description">
    <h1 class="story-description__header" v-text="story.title" />
    <div
      v-if="story.categories.length"
      class="story-description__categories pb-2"
    >
      <v-chip
        v-for="category in story.categories"
        :key="category"
        class="story-description__category mr-3 mt-2"
        color="secondary_lightest"
        label
      >
        {{ category }}
      </v-chip>
    </div>
    <div class="d-flex mt-3 mb-6">
      <Avatar :src="story.publication.attributes.userAvatar" />
      <div class="story-description__author ml-4" v-text="authorName" />
    </div>
    <div
      v-if="story.description"
      class="story-description__description mb-1"
      :class="{'story-description__description--collapse' : !showMore}"
    >
      <div ref="storyDescriptionWrapper">
        <p
          v-for="(text, index) in storyDescription"
          :key="index"
          v-text="text"
        />
      </div>
    </div>
    <v-btn
      v-if="descriptionIsCollapsed"
      class="story-description__show-more"
      plain
      @click="showMore = !showMore"
    >
      {{showMore ? 'Show less' : 'Show more'}}
      <v-icon color="primary">mdi-chevron-{{ showMore ? 'up' : 'down' }}</v-icon>
    </v-btn>
    <div
      v-if="story.dateAsText.length"
      class="story-description__dates mt-4 mb-5"
      v-text="story.dateAsText"
    />
  </div>
</template>

<script>
import { mapState } from 'vuex'
import Avatar from '../Elements/Avatar'

export default {
  components: {
    Avatar
  },
  data: () => ({
    showMore: false,
    descriptionIsCollapsed: false
  }),
  computed: {
    ...mapState({
      story: store => store.stories.story
    }),
    storyDescription() {
      return this.story.description.split('\n')
    },
    isPublic() {
         return this.story.publication?.attributes?.shareType ==='community'
    },
    communityName () {
      return this.story.community.name
    },
    authorName(){
      return this.isPublic ? this.communityName : this.story.publication.attributes.userName
    }
  },
  mounted() {
    this.setMinHeight()
  },
  updated() {
    this.setMinHeight()
  },
  methods: {
    setMinHeight() {
      this.$nextTick(() => {
        this.descriptionIsCollapsed = this.$refs.storyDescriptionWrapper?.clientHeight > 82
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.story-description {
  &__header {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    color: $color-tertiary;
  }
  &__category {
    border-radius: 80px !important;
    font-weight: bold;
    font-size: 12px !important;
    line-height: 180%;
    color: $color-tertiary !important;
    max-height: 28px;
  }
  &__author {
    font-weight: bold;
    font-size: 20px;
    color: $color-tertiary;
  }
  
  &__description {
    word-break: break-word;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-text !important;
    &--collapse {
      max-height: 82px;
      overflow: hidden;
    }
    div {
      min-height: 24px;
    }
  }
  &__show-more {
    padding-left: 0 !important;
    color: $color-primary;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;
  }
  
  &__dates {
    font-family: Lato;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-tertiary;
  }
}

.content-wrapper {
  padding: 1em !important;
}
</style>
