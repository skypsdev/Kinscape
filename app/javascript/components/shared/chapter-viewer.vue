<template>
  <div class="display-section main-div-design chapter_data">
    <span
      class="rich-body"
      v-html="contentHtml"
    />
  </div>
</template>

<script>
export default {
  props: {
    section: {
      type: Object
    }
  },
  computed: {
    contentHtml () {
      let title = this.section.attributes.title
      title = title === null ? '' : title
      let sectionHeader = '<h1>' + title + '</h1>'
      let html = sectionHeader + this.section.attributes.rich_body.html
      html = html.split('<br>').join('\n')

      var regexYoutube = new RegExp(
        '(?!.*\\/action-text-attachment>)' +
        '<a [^>]*(href=".*(?:https?:\\/)?(?:www\\.)?(?:youtu\\.' +
        'be\\/|youtube\\.com\\/(?:embed\\/|v\\/|watch\\?v=|watch\\' +
        '?.+&v=))((\\w|-){11})(?:&[^<]+)?).*(<\\/a>)', 'g'
      )

      if (regexYoutube.test(html)) {
        console.log('regexYoutube')
        const youtube = `
        <div class='iframe-wrapper'>
          <iframe src='https://www.youtube.com/embed/$2'></iframe>
        </div>
        `
        html = html.replace(regexYoutube, youtube)
      }

      var regexYoutubeIframe = new RegExp([
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

      var regexVimeoIframe = new RegExp(
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

      var regexVimeo = new RegExp(
        '(?!.*\\/action-text-attachment>)' +
        '<a [^>]*(href=".*?(http|https)?:\\/\\/(www\\.|player\\.' +
        ')?vimeo\\.com\\/(?:channels\\/(?:\\w+\\/)?|groups\\/([^\\' +
        '/]*)\\/videos\\/|video\\/|)(\\d+)(?:|\\/\\?)).*?(<\\/a>)', 'g'
      )

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

<style scoped>
.main-div-design{
    width: 100%;
    /* display: flex; */
    justify-content: center;
    margin-bottom: 30px;
}
</style>
