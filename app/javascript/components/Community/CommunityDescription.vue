<template>
  <div class="community-description">
    <h1 class="community-description__header" v-text="community.name" />
    <v-chip class="mt-3">
      {{ community.type.toUpperCase() }}
    </v-chip>
    <h3 class="community-description__motto mt-5" v-text="community.motto"/>
    <div
        v-if="communityDescription"
        class="community-description__description mt-7 mb-1"
        :class="{'community-description__description--collapse' : !showMore}"
    >
      <div ref="communityDescriptionWrapper">
        <p
            v-for="(text, index) in communityDescription"
            :key="index"
            v-text="text"
        />
      </div>
    </div>
    <v-btn
        v-if="descriptionIsCollapsed"
        class="community-description__show-more"
        plain
        @click="showMore = !showMore"
    >
      {{showMore ? $i18n.t('communities.description.less') : $i18n.t('communities.description.more') }}
      <v-icon color="primary">mdi-chevron-{{ showMore ? 'up' : 'down' }}</v-icon>
    </v-btn>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  data: () => ({
    showMore: false,
    descriptionIsCollapsed: false
  }),
  computed: {
    ...mapState({
      community: store => store.families.community
    }),
    communityDescription() {
      return this.community.description?.split('\n')
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
        this.descriptionIsCollapsed = this.$refs.communityDescriptionWrapper?.clientHeight > 82
      })
    }
  }
}
</script>

<style lang="scss" scoped>
.community-description {
  &__header {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    color: $color-tertiary;
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
  &__motto {
    font-family: Lato;
    font-style: italic;
    font-size: 20px;
    font-weight: normal;
    line-height: 24px;
    color: $color-grey;
  }
}

.content-wrapper {
  padding: 1em !important;
}
</style>
