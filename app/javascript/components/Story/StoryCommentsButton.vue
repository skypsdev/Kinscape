<template>
  <v-btn
    rounded
    outlined
    color="primary"
    elevation="0"
    :disabled="disabled"
    :title="$i18n.t('stories.action_button.comment_title')"
    @click="showStoryComments"
    width="170"
  >
    <v-icon left>mdi-forum-outline</v-icon>
    {{ $i18n.t('stories.action_button.comment', { count: commentsCount }) }}
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
      allComments: state => state.comments.allComments,
      publicationId: store => store.stories.story.publication.id
    }),
    commentsCount() {
      const comments = this.allComments.filter((comment) => comment.attributes.commentableType === 'Publication')
      let commentsLength = comments.length
      comments.forEach((comment) => commentsLength += comment.relationships?.comments?.data?.length || 0)
      return commentsLength
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    showStoryComments() {
      this.setDialog({
        component: 'CommentsDialog',
        title: this.$i18n.t('stories.comments.story_comments'),
        data: {
          commentableId: this.publicationId,
          parentId: this.publicationId
        }
      })
    }
  }
}
</script>
