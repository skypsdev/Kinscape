<template>
  <div class="chapter pb-10">
    <div v-if="!chapter.loader">
      <h3 class="chapter__title" v-text="chapter.attributes.title"/>
      <div class="d-flex align-center mt-3 mb-6">
        <div class="chapter__date d-flex align-center">
          <v-icon>mdi-circle-small</v-icon>{{ $moment(chapter.attributes.created_at).format('Do MMM YYYY') }}
        </div>
      </div>
      <div :id="`chapter-content${chapter.id}`" class="chapter__content" v-html="contentHtml"/>
      <div class="chapter__toolbar mt-3">
        <ChapterLikeButton :chapter="chapter" />
        <v-btn
          class="pl-0"
          plain
          color="primary"
          @click="showComments = !showComments"
        >
          <v-icon class="mr-1" color="primary">mdi-forum-outline</v-icon>
          {{ $i18n.t('stories.comments.other', { count: commentsCount }) }}
          <v-icon color="primary">mdi-chevron-{{ showComments ? 'up' : 'down' }}</v-icon>
        </v-btn>
      </div>
      <Comments
        v-if="showComments"
        commentable-type="Chapter"
        :commentable-id="chapter.id"
        :parent-id="member.id"
        parent-type="Kinship"
      />
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import Comments from '../Elements/Comments'
import ChapterLikeButton from "@/components/Elements/Chapters/ChapterLikeButton"

let previousAudio
document.addEventListener('play', function (e) {
  if (previousAudio && previousAudio !== e.target) {
    previousAudio.pause()
  }
  previousAudio = e.target
}, true)

export default {
  components: {
    Comments,
    ChapterLikeButton
  },
  props: {
    chapter: {
      type: Object,
      required: true
    }
  },
  data: () => ({
    showComments: false,
  }),
  computed: {
    ...mapState({
      allComments: state => state.comments.allComments,
      member: state => state.members.member
    }),
    commentsCount() {
      const comments = this.allComments.filter((comment) => comment.attributes.commentableId === this.chapter.id)
      let commentsLength = comments.length
      comments.forEach((comment) => commentsLength += comment.attributes?.commentsCount || 0)
      return commentsLength
    },
    contentHtml () {
      let html = this.chapter.attributes.rich_body.html
      html = html.split('<br>').join('\n')

      const regexYoutube = new RegExp(
          '(?!.*\\/action-text-attachment>)' +
          '<a [^>]*(href=".*(?:https?:\\/)?(?:www\\.)?(?:youtu\\.' +
          'be\\/|youtube\\.com\\/(?:embed\\/|v\\/|watch\\?v=|watch\\' +
          '?.+&v=))((\\w|-){11})(?:&[^<]+)?).*(<\\/a>)', 'g')

      if (regexYoutube.test(html)) {
        console.log('regexYoutube')
        const youtube = `
        <div>
          <iframe src='https://www.youtube.com/embed/$2' width="100%" height="550" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        </div>
        `
        html = html.replace(regexYoutube, youtube)
      }

      const regexYoutubeIframe = new RegExp([
        /&lt;iframe .*? src=".*(?:https?:\/)?/,
        /(?:www\.)?/,
        /(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))/,
        /((\w|-){11})(?:&[^<]+)?.*\/iframe&gt;/
      ].map(r => r.source).join(''), 'g')

      if (regexYoutubeIframe.test(html)) {
        console.log('regexYoutubeIframe')
        const youtube = `
        <div>
          <iframe src='https://www.youtube.com/embed/$1' width="100%" height="550" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        </div>
        `
        html = html.replace(regexYoutubeIframe, youtube)
      }

      // For vimeo

      const regexVimeoIframe = new RegExp(
          '&lt;iframe.*? src=".*?(http|https)?:\\/\\/(www\\.|pla' +
          'yer\\.)?vimeo\\.com\\/(?:channels\\/(?:\\w+\\/)?|groups\\' +
          '/([^\\/]*)\\/videos\\/|video\\/|)(\\d+)(?:|\\/\\?).*?&lt;' +
          '\\/iframe&gt;', 'g')

      if (regexVimeoIframe.test(html)) {
        console.log('regexVimeoIframe')
        const iframe = `
        <div>
          <iframe src='//player.vimeo.com/video/$4' width="100%" height="550" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        </div>
        `
        html = html.replace(regexVimeoIframe, iframe)
      }

      const regexVimeo = new RegExp(
          '(?!.*\\/action-text-attachment>)' +
          '<a [^>]*(href=".*?(http|https)?:\\/\\/(www\\.|player\\.' +
          ')?vimeo\\.com\\/(?:channels\\/(?:\\w+\\/)?|groups\\/([^\\' +
          '/]*)\\/videos\\/|video\\/|)(\\d+)(?:|\\/\\?)).*?(<\\/a>)', 'g')

      if (regexVimeo.test(html)) {
        console.log('regexVimeo')
        const iframe = `
        <div>
          <iframe src='//player.vimeo.com/video/$5' width="100%" height="550" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>
        </div>
        `
        html = html.replace(regexVimeo, iframe)
      }

      html = html.split('\n').join('<br>')
      return html
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
    color: #4B4B4B;
  }
  &__content {
    font-size: 18px;
    line-height: 27px;
    text-align: justify;
  }
  &__author {
    font-weight: bold;
    font-size: 16px;
    color: #4B4B4B;
  }
  &__date {
    font-weight: normal;
    font-size: 13px;
    color: #939393;
  }
}
</style>
