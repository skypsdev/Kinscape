<template>
  <div class="chapter-comments pt-6">
    <v-btn
      v-if="displayedCommentForm !== commentableId"
      rounded
      outlined
      color="primary"
      elevation="0"
      :title="$i18n.t('stories.action_button.comment_title')"
      @click="openCommentForm(commentableId)"
      width="170"
    >
      <v-icon class="flip-h" left>mdi-message-plus-outline</v-icon>
      {{ $i18n.t('comments.add_comment') }}
    </v-btn>

    <div v-if="displayedCommentForm === commentableId">
      <v-textarea
        class="comments__textarea"
        no-resize
        outlined
        hide-details
        autofocus
        rows="3"
        v-model="newComment"
        :placeholder="$i18n.t('comments.new')"
      />
      <div class="mt-2 text-right">
        <v-btn
          class="comments__button--save"
          :disabled="newComment.length < 2 || isLoading"
          color="primary"
          elevation="0"
          @click="addNewComment(commentableId, commentableType)"
        >
          {{ $i18n.t('comments.post_comment') }}
        </v-btn>
      </div>
    </div>

    <v-list>
      <v-list-item
        v-for="comment in comments"
        :key="comment.title"
        class="px-0"
      >
        <v-list-item-content>
          <v-list-item-title class="d-flex flex-row align-center">
            <Avatar
              :src="comment.attributes.userAvatarUrl"
              size="small"
            />
            <div class="comments__user-name ml-2">
              {{comment.attributes.userName}}
            </div>
            <div class="comments__date ml-1" v-html="formatDate(comment.attributes.createdAt)" />
            <v-btn
              v-if="canRemoveComment(comment)"
              class="comments__button--remove"
              plain
              color="primary"
              x-small
              :disabled="isLoading"
              @click="removeComment(comment.id, commentableType)"
            >
              <v-icon small>mdi-close</v-icon>
              {{ $i18n.t('comments.remove') }}
            </v-btn>
          </v-list-item-title>
          <div class="comments__content mt-2">
            <p
              v-for="(text, index) in comment.attributes.body.split('\n')"
              :key="index"
              v-text="text"
            />
          </div>
          <div class="comments__toolbar">
            <v-btn
              class="pl-0"
              plain
              color="primary"
              :disabled="isLoading"
              @click="openCommentForm(comment.id, true)"
            >
              <v-icon class="mr-1">mdi-reply</v-icon>
              {{ $i18n.t('comments.reply') }}
            </v-btn>
            <v-btn
              v-if="replies(comment.id).length"
              plain
              color="grey"
              @click="handleShowReplies(comment.id)"
            >
              {{ activeReplies(comment.id) ? $i18n.t('comments.hide_replies') : $i18n.t('comments.see_replies') }} ({{ replies(comment.id).length }})
              <v-icon color="grey">mdi-chevron-{{ activeReplies(comment.id) ? 'up' : 'down' }}</v-icon>
            </v-btn>
          </div>
          <div v-if="activeReplies(comment.id)" class="comments__replies">
            <v-list class="py-0">
              <v-list-item
                v-for="reply in replies(comment.id)"
                :key="reply.title"
                class="px-0 pt-0"
              >
                <v-list-item-content class="pt-0">
                  <v-list-item-title class="d-flex flex-row align-center">
                    <Avatar
                      :src="reply.attributes.userAvatarUrl"
                      size="small"
                    />
                    <div class="comments__user-name ml-2">
                      {{reply.attributes.userName}}
                    </div>
                    <div class="comments__date ml-1" v-html="formatDate(reply.attributes.createdAt)" />
                    <v-btn
                      v-if="canRemoveComment(reply)"
                      class="comments__button--remove"
                      plain
                      color="primary"
                      x-small
                      :disabled="isLoading"
                      @click="removeComment(reply.id, 'Comment')"
                    >
                      <v-icon small>mdi-close</v-icon>
                      {{ $i18n.t('comments.remove') }}
                    </v-btn>
                  </v-list-item-title>
                  <div class="comments__content mt-2">
                    <p
                      v-for="(text, index) in reply.attributes.body.split('\n')"
                      :key="index"
                      v-text="text"
                    />
                  </div>
                </v-list-item-content>
              </v-list-item>
            </v-list>
            <div v-if="displayedCommentForm === comment.id">
              <v-textarea
                class="comments__textarea"
                no-resize
                outlined
                hide-details
                autofocus
                rows="3"
                v-model="newComment"
                :placeholder="$i18n.t('comments.type_your_reply')"
              />
              <div class="mt-2 text-right">
                <v-btn
                  class="comments__button--save"
                  :disabled="newComment.length < 2 || isLoading"
                  color="primary"
                  elevation="0"
                  @click="addNewComment(comment.id, 'Comment')"
                >
                  {{ $i18n.t('comments.post_comment') }}
                </v-btn>
              </div>
            </div>
          </div>
        </v-list-item-content>
      </v-list-item>
    </v-list>
  </div>
</template>
<script>
import {mapActions, mapState} from 'vuex'
import Avatar from './Avatar'

export default {
  components: {
    Avatar
  },
  props: {
    parentId: {
      type: String,
      required: true
    },
    parentType:{
      type: String,
      required: true
    },
    commentableType: {
      type: String,
      required: true
    },
    commentableId: {
      type: String,
      required: true
    }
  },
  data: () => ({
    newComment: '',
    displayedCommentForm: '',
    showReplies: []
  }),
  computed: {
    ...mapState({
      currentUser: store => store.core.user,
      isLoading: store => store.comments.loading,
      allComments: store => store.comments.allComments
    }),
    comments() {
      return this.allComments.filter(comment =>
        comment.attributes.commentableId.toString() === this.commentableId &&
        comment.attributes.commentableType === this.commentableType
      )
    }
  },
  methods: {
    ...mapActions({
      addComment: 'comments/addComment',
      deleteComment: 'comments/deleteComment'
    }),
    replies(id) {
      const replies = this.allComments.filter((comment) => comment.attributes.commentableType === 'Comment')
      return replies.filter(comment => comment.attributes.commentableId.toString() === id.toString())
    },
    openCommentForm(id, isReply) {
      this.displayedCommentForm = id
      if (isReply) {
        if (!this.showReplies.includes(id)) this.showReplies.push(id)
      }
    },
    addNewComment (commentableId, commentableType) {
      this.addComment({
        parent: { parentId: this.parentId, parentType: this.parentType },
        body: this.newComment,
        commentableType,
        commentableId
      })
      this.newComment = ''
      this.displayedCommentForm = ''
    },
    removeComment (commentableId, commentableType) {
      this.deleteComment({
        parentId: this.parentId,
        id: commentableId,
        type: commentableType
      })
    },
    canRemoveComment(comment) {
      return this.$possible('destroy', 'Comment', {
        userId: comment.attributes.userId,
        publication: { familyId: comment.attributes.familyId }
      })
    },
    handleShowReplies(id) {
      if (this.showReplies.includes(id)) {
        this.showReplies = this.showReplies.filter(el => el !== id)
      } else {
        this.showReplies.push(id)
      }
    },
    activeReplies(id) {
      return this.showReplies.includes(id)
    },
    formatDate(createdAt) {
      return '<span class="date-dot">&bull;</span>' + this.$moment(createdAt).format('Do MMM YYYY')
    }
  }
}
</script>
<style lang="scss" scoped>
.comments {
  &__replies {
    border-left: 1px solid $color-medium-grey;
    margin-top: 24px;
    padding-left: 20px;
  }
  &__user-name {
    font-style: normal;
    font-weight: bold;
    font-size: 13px;
    color: $color-tertiary;
  }
  &__date {
    font-weight: 400;
    font-size: 13px;
    color: $color-grey;
    display: flex;
    align-items: center;
  }
  &__content {
    p {
      font-style: normal;
      font-weight: normal;
      font-size: 13px;
      line-height: 16px;
      text-align: justify;
      padding-right: 14px;
      color: $color-tertiary;
      margin-bottom: 8px;
    }
  }
  &__button {
    &--remove {
      font-style: normal;
      font-weight: bold;
      font-size: 12px;
      color: #E95631;
    }
  }
  &__textarea.v-textarea textarea {
    line-height: 20px;
    margin-bottom: 12px;
  }
}
</style>
