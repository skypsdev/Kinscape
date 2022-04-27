<template>
  <div>
    <template v-if="sections.loading">
      <content-loader
        v-for="n in 2"
        :key="n"
        :height="264"
        :width="1107"
        :speed="2"
        primary-color="#f3f3f3"
        secondary-color="#ecebeb"
      >
        <rect
          x="87.26"
          y="149.97"
          rx="3"
          ry="3"
          width="9.33"
          height="94.01"
        />
        <rect
          x="125"
          y="170.61"
          rx="3"
          ry="3"
          width="477.2"
          height="25.09"
        />
        <rect
          x="126"
          y="222.64"
          rx="3"
          ry="3"
          width="164.23"
          height="11.09"
        />
        <circle
          cx="22.76"
          cy="22.76"
          r="21.76"
        />
        <rect
          x="242.31"
          y="99.61"
          rx="0"
          ry="0"
          width="0"
          height="0"
        />
        <rect
          x="542.13"
          y="133.61"
          rx="0"
          ry="0"
          width="0"
          height="0"
        />
        <rect
          x="530.33"
          y="125.61"
          rx="0"
          ry="0"
          width="0"
          height="0"
        />
        <rect
          x="2.31"
          y="86.61"
          rx="0"
          ry="0"
          width="45.96"
          height="94.91"
        />
        <rect
          x="88.63"
          y="101.61"
          rx="0"
          ry="0"
          width="167"
          height="28"
        />
        <rect
          x="269.63"
          y="100.61"
          rx="0"
          ry="0"
          width="292.25"
          height="28"
        />
        <rect
          x="935.63"
          y="99.61"
          rx="0"
          ry="0"
          width="85.17"
          height="28"
        />
      </content-loader>
    </template>
    
    <infinite-loading
      v-if="hasMorePages"
      spinner="spiral"
      @infinite="getMoreChapters"
    >
      <div slot="no-more" />
    </infinite-loading>
  </div>
</template>

<script>
import { ContentLoader } from 'vue-content-loader'
import {mapActions, mapGetters, mapState} from 'vuex'

export default {
  components: { ContentLoader },
  computed: {
    ...mapState({
      story: store => store.stories.story,
      sections: state => state.sections
    }),
    ...mapGetters({
      hasMorePages: 'sections/hasMorePages'
    }),
    publicationId () {
      return this.$route.params.id
    }
  },
  methods: {
    ...mapActions({
      getChapters: 'sections/loadNext'
    }),
    async getMoreChapters ($state) {
      try {
        await this.getChapters({id: this.story.publication.id})
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
