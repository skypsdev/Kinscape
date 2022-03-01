<template>
  <div class="chapter pb-10">
    <div v-if="!chapter.loader">
      <h3 class="chapter__title" v-text="chapter.attributes.title"/>
      <div class="d-flex align-center mt-3 mb-6">
        <div class="chapter__date d-flex align-center">
          <v-icon>mdi-circle-small</v-icon>{{ $moment(chapter.attributes.created_at).format('Do MMM YYYY') }}
        </div>
      </div>
      <div v-html="contentHtml"/>
    </div>
  </div>
</template>

<script>
let previousAudio
document.addEventListener('play', function (e) {
  if (previousAudio && previousAudio !== e.target) {
    previousAudio.pause()
  }
  previousAudio = e.target
}, true)

export default {
  props: {
    chapter: {
      type: Object,
      required: true
    }
  },
  computed: {
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
        <div class='iframe-wrapper'>
          <iframe src='https://www.youtube.com/embed/$2'></iframe>
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
        <div class='iframe-wrapper'>
          <iframe src='https://www.youtube.com/embed/$1'></iframe>
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
        <div class='iframe-wrapper'>
          <iframe src='//player.vimeo.com/video/$4'></iframe>
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
        <div class='iframe-wrapper'>
          <iframe src='//player.vimeo.com/video/$5'></iframe>
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
