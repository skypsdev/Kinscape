<template>
  <div class="chapter pb-10">
    <div v-if="!chapter.loader" class="is-relative">
      <h3 class="chapter__title" v-text="chapter.attributes.title"/>
      <div class="d-flex align-center mt-3 mb-6">
        <Avatar v-if="shareType === 'community'" :src="chapter.attributes.author_avatar_url" />
        <div v-if="shareType === 'community'" class="chapter__author ml-4" v-text="chapter.attributes.author_name" />
        <div class="chapter__date d-flex align-center" v-html="formatDate(chapter.attributes.created_at)"/>
      </div>
      <v-btn
          v-if="canDestroyChapter"
          class="chapter-delete_btn"
          outlined
          x-large
          color="primary"
          @click="openChapterDeleteDialog"
      >
        <v-icon>mdi-delete-outline</v-icon>
        <span class="pl-2 hidden-sm-and-down">
          {{$i18n.t('stories.chapters.delete')}}
        </span>
      </v-btn>
      <div :id="`chapter-content${chapter.id}`" class="chapter__content" v-html="contentHtml"/>
      <div
          v-if="shareType !== 'private'"
          class="chapter__toolbar mt-3"
      >
        <ChapterLikeButton :chapter="chapter" :isStory="true"/>
        <v-btn
          class="pl-0"
          plain
          color="primary"
          @click="showComments = !showComments"
        >
          <v-icon class="mr-1" color="primary">mdi-forum-outline</v-icon>
          {{ $i18n.t('stories.comments.other' , { count: commentsCount }) }}
          <v-icon color="primary">mdi-chevron-{{ showComments ? 'up' : 'down' }}</v-icon>
        </v-btn>
      </div>
      <Comments
        v-if="showComments"
        commentable-type="Section"
        :commentable-id="chapter.id"
        :parent-id="publicationId"
        parent-type="Publication"
      />
    </div>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import Avatar from '../Elements/Avatar'
import Comments from '../Elements/Comments'
import ChapterLikeButton from "@/components/Elements/Chapters/ChapterLikeButton";
import {regexYoutube, regexYoutubeIframe, regexVimeo, regexVimeoIframe} from '../../utils/regex'
import { delay, on } from '@/utils/functions'

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
    Comments,
    ChapterLikeButton
  },
  props: {
    chapter: {
      type: Object,
      required: true
    },
    shareType: {
      type: String,
      required: true
    },
    canDestroyChapter: {
      type: Boolean,
      default: false
    },
  },
  data: () => ({
    showComments: false,
    imagesRefs: [],
    lightboxRef: null,
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
      const replaceIframe = (regex, url) => html.replace(regex, `<div><iframe src='${url}' width="100%" height="550" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe></div>`)

      let html = this.chapter.attributes.rich_body.html
      html = html.split('<br>').join('\n')
      html = replaceIframe(regexYoutube,'https://www.youtube.com/embed/$2')
      html = replaceIframe(regexYoutubeIframe,'https://www.youtube.com/embed/$1')
      html = replaceIframe(regexVimeoIframe,'//player.vimeo.com/video/$4')
      html = replaceIframe(regexVimeo,'//player.vimeo.com/video/$5')
      return html.split('\n').join('<br>')
    }
  },
  async mounted() {
    await delay(250)
    this.initLightbox()
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    formatDate(createdAt) {
      return '<span class="date-dot">&bull;</span>' + this.$moment(createdAt).format('Do MMM YYYY')
    },
    openChapterDeleteDialog() {
      this.setDialog({
        title: this.$i18n.t('stories.chapters.delete'),
        component: 'ChapterDeleteDialog',
        data: {
          section: this.chapter
        }
      })
    },
    initLightbox() {
      this.imagesRefs = document.querySelectorAll(`#chapter-content${this.chapter.id} action-text-attachment`);

      Array.from(this.imagesRefs).forEach((image) => {
        on(image, 'click', () => {
          this.setDialog({
            component: 'PreviewImageDialog',
            size: 'big',
            title: '',
            data: {
              imageUrl: image.querySelectorAll('img')[0].src,
              caption: image.querySelectorAll('p')[0]?.innerText
            }
          })
        });
      });
    },
  }
}
</script>

<style lang="scss" scoped>
.is-relative {
  position: relative;
}

.chapter {
  &-delete_btn {
    position: absolute;
    top: 0;
    right: 0;
  }
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
        &__caption {
          text-align: center;
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
::v-deep .image-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 10px;
  & img {
    max-width: 100%;
    max-height: 80vh;
  }
}
</style>
