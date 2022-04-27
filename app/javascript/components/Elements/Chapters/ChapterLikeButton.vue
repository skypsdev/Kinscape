<template>
  <v-btn
      text
      color="primary"
      class="mx-1"
      :disabled="disabled || isLoading"
      :title="$i18n.t('stories.action_button.' + actionName)"
      @click="handleAppreciate"
  >
    <v-icon left>{{appreciationId ?'mdi-heart' : 'mdi-heart-outline'}}</v-icon>
    {{ appreciationsCount }}
  </v-btn>
</template>

<script>
import {mapActions, mapState} from 'vuex'

export default {
  props: {
    disabled: {
      type: Boolean,
      default: false
    },
    chapter: {
      type: Object,
      required: true
    },
    isStory : {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      isLoading: state => state.stories.loading,
      publicationId: state => state.stories.story.publication.id,
      kinshipId: state => state.members.member.id,
    }),
    actionName () {
      return this.appreciationId ? 'unnappreciate' : 'appreciate'
    },
    appreciationId () {
      return this.chapter.attributes.appreciation_id
    },
    appreciationsCount () {
      return this.chapter.attributes.appreciations_count
    },
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError',
      createChapterAppreciation: 'stories/createChapterAppreciation',
      removeChapterAppreciation: 'stories/removeChapterAppreciation',
      createFamilyChapterAppreciation: 'families/createFamilyChapterAppreciation',
      removeFamilyChapterAppreciation: 'families/removeFamilyChapterAppreciation'
    }),
    appreciateChapter() {
      const { appreciationId, publicationId, chapter } = this
      if (appreciationId) {
        this.removeChapterAppreciation({ appreciationId })
      } else {
        this.createChapterAppreciation({
          reaction: 'smile',
          appreciableId: chapter.id,
          appreciableType: 'Section',
          publicationId: publicationId
        })
      }
    },
    appreciateFamily() {
      const { appreciationId, kinshipId, chapter } = this
      if (appreciationId) {
        this.removeFamilyChapterAppreciation({ kinshipId, appreciationId })
      } else {
        this.createFamilyChapterAppreciation({ kinshipId,
          params: {
            reaction: 'smile',
            appreciableId: chapter.id,
            appreciableType: 'Chapter'
          }
        })
      }
    },
    handleAppreciate () {
      const { isStory, appreciateChapter, appreciateFamily } = this
      isStory ? appreciateChapter() : appreciateFamily()
    }
  }
}
</script>
