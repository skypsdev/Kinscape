<template>
  <div>
    <template v-if="isLoading">
      <content-loader
        :height="528"
        :width="1058"
        :speed="2"
        primary-color="#f3f3f3"
        secondary-color="#ecebeb"
      >
        <rect
          x="6"
          y="6"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="272"
          y="6"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="538"
          y="6"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="804"
          y="6"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="6"
          y="272"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="272"
          y="272"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="538"
          y="272"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
        <rect
          x="804"
          y="272"
          rx="0"
          ry="0"
          width="245"
          height="245"
        />
      </content-loader>
    </template>
    <infinite-loading
      v-if="hasMorePages"
      spinner="spiral"
      force-use-infinite-wrapper
      @infinite="getMoreStories"
    >
      <div slot="no-more" />
    </infinite-loading>
  </div>
</template>

<script>
import { ContentLoader } from 'vue-content-loader'
import {mapActions, mapGetters, mapState} from "vuex";

export default {
  components: { ContentLoader },
  computed: {
    ...mapState({
      isLoading: state => state.stories.loading
    }),
    ...mapGetters({
      hasMorePages: 'stories/hasMorePages'
    })
  },
  methods: {
    ...mapActions({
      getPublications: 'stories/getPublications'
    }),
    async getMoreStories ($state) {
      try {
        await this.getPublications()
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    }
  }
}
</script>
