<template>
  <v-btn
    rounded
    :outlined="!appreciationId"
    color="primary"
    elevation="0"
    width="170"
    :disabled="disabled || isLoading"
    :title="$i18n.t('stories.action_button.' + actionName)"
    @click="handleAppreciate"
  >
    <v-icon left>{{appreciationId ?'mdi-heart' : 'mdi-heart-outline'}}</v-icon>
    {{ $i18n.t('stories.action_button.like', { count: appreciationsCount }) }}
  </v-btn>
</template>

<script>
import {mapActions, mapState} from 'vuex'

export default {
  props: {
    disabled: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      isLoading: state => state.stories.loading,
      appreciationsCount: state => state.stories.story.publication.attributes.appreciationsCount,
      appreciationId: state => state.stories.story.publication.attributes.appreciationId,
      publicationId: state => state.stories.story.publication.id
    }),
    actionName () {
      return this.appreciationId ? 'unnappreciate' : 'appreciate'
    }
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError',
      createStoryAppreciation: 'stories/createStoryAppreciation',
      removeStoryAppreciation: 'stories/removeStoryAppreciation'
    }),
    handleAppreciate () {
      const {appreciationId, publicationId} = this

      if (appreciationId) {
        this.removeStoryAppreciation({ appreciationId })
      } else {
        this.createStoryAppreciation({
          reaction: 'smile',
          appreciableId: this.publicationId,
          appreciableType: 'Publication',
          publicationId: publicationId
        })
      }
    }
  }
}
</script>
