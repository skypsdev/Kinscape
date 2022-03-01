<template>
  <div class="chapter pb-10">
    <div v-if="!chapter.loader">
      <h3 class="chapter__title" v-text="chapter.attributes.title"/>
      <div class="d-flex align-center mt-3 mb-6">
        <Avatar :src="chapter.attributes.author_avatar_url" />
        <div class="chapter__author ml-4" v-text="chapter.attributes.author_name" />
        <div class="chapter__date d-flex align-center" v-html="formatDate(chapter.attributes.created_at)"/>
      </div>
      <div class="chapter__content" v-html="contentHtml"/>
      <div class="chapter__toolbar mt-3">
        <v-btn
          class="pl-0"
          plain
          color="primary"
          @click="showComments = !showComments"
        >
          <v-icon class="mr-1" color="primary">mdi-forum-outline</v-icon>
          {{$i18n.t('stories.comments.other' , { count: commentsCount }) }}
          <v-icon color="primary">mdi-chevron-{{ showComments ? 'up' : 'down' }}</v-icon>
        </v-btn>
      </div>
      <Comments
        v-if="showComments"
        commentable-type="Section"
        :commentable-id="chapter.id"
        :parent-id="publicationId"
      />
    </div>
  </div>
</template>

<script>
import {mapState} from 'vuex'
import Avatar from '../Elements/Avatar'
import Comments from '../Elements/Comments'
import {regexYoutube, regexYoutubeIframe, regexVimeo, regexVimeoIframe} from '../../utils/regex'

// TODO
let previousAudio
document.addEventListener('play', function (e) {
  if (previousAudio && previousAudio !== e.target) previousAudio.pause()
  previousAudio = e.target
}, true)
//

export default {
  components: {
    Avatar,
    Comments
  },
  props: {
    chapter: {
      type: Object,
      required: true
    }
  },
  data: () => ({
    showComments: false
  }),
  computed: {
    ...mapState({
      allComments: state => state.comments.allComments,
      publicationId: store => store.stories.story.publication.id
    }),
    commentsCount() {
      const comments = this.allComments.filter((comment) => comment.attributes.commentableId.toString() === this.chapter.id)
      let commentsLength = comments.length
      comments.forEach((comment) => commentsLength += comment.relationships?.comments?.data?.length || 0)
      return commentsLength
    },
    contentHtml () {
      const replaceIframe = (regex, url) => html.replace(regex, `<div class='iframe-wrapper'><iframe src='${url}'></iframe></div>`)
  
      let html = this.chapter.attributes.rich_body.html
      html = html.split('<br>').join('\n')
      html = replaceIframe(regexYoutube,'https://www.youtube.com/embed/$2')
      html = replaceIframe(regexYoutubeIframe,'https://www.youtube.com/embed/$1')
      html = replaceIframe(regexVimeoIframe,'//player.vimeo.com/video/$4')
      html = replaceIframe(regexVimeo,'//player.vimeo.com/video/$5')
      return html.split('\n').join('<br>')
    }
  },
  methods: {
    formatDate(createdAt) {
      return '<span class="date-dot">&bull;</span>' + this.$moment(createdAt).format('Do MMM YYYY')
    }
  }
}
</script>

<style lang="scss" scoped>
.chapter {
  &__title {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 32px;
    line-height: 43px;
    color: $color-tertiary;
  }
  &__content {
    font-size: 18px;
    line-height: 26px;
    letter-spacing: normal;
    font-weight: normal;
    color: $color-text;
    &::v-deep {
      blockquote {
        border: none !important;
        font-size: 1.6em;
        font-style: italic;
        line-height: 1.4em;
        margin: 1.4em 0 !important;
        padding: 0 !important;
        text-align: center;
        &:before {
          content: "\201C";
        }
        &:after {
          content: "\201D";
        }
      }
      .attachment {
        margin-top: 26px;
        margin-bottom: 16px;
        img {
          max-width: 100%;
        }
      }
    }
  }
  &__author {
    font-weight: bold;
    font-size: 16px;
    color: $color-tertiary;
  }
  &__date {
    font-weight: normal;
    font-size: 13px;
    color: $color-grey;
    display: flex;
    align-items: center;
  }
  &::v-deep .date-dot {
    padding-right: 6px;
    padding-left: 4px;
    font-size: 10px;
    color: $color-medium-grey;
  }
}
</style>
