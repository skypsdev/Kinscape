const regexYoutube = new RegExp(
  '(?!.*\\/action-text-attachment>)' +
  '<a [^>]*(href=".*(?:https?:\\/)?(?:www\\.)?(?:youtu\\.' +
  'be\\/|youtube\\.com\\/(?:embed\\/|v\\/|watch\\?v=|watch\\' +
  '?.+&v=))((\\w|-){11})(?:&[^<]+)?).*(<\\/a>)', 'g')

const regexYoutubeIframe = new RegExp([
  /&lt;iframe .*? src=".*(?:https?:\/)?/,
  /(?:www\.)?/,
  /(?:youtu\.be\/|youtube\.com\/(?:embed\/|v\/|watch\?v=|watch\?.+&v=))/,
  /((\w|-){11})(?:&[^<]+)?.*\/iframe&gt;/
].map(r => r.source).join(''), 'g')

const regexVimeo = new RegExp(
  '(?!.*\\/action-text-attachment>)' +
  '<a [^>]*(href=".*?(http|https)?:\\/\\/(www\\.|player\\.' +
  ')?vimeo\\.com\\/(?:channels\\/(?:\\w+\\/)?|groups\\/([^\\' +
  '/]*)\\/videos\\/|video\\/|)(\\d+)(?:|\\/\\?)).*?(<\\/a>)', 'g')

const regexVimeoIframe = new RegExp(
  '&lt;iframe.*? src=".*?(http|https)?:\\/\\/(www\\.|pla' +
  'yer\\.)?vimeo\\.com\\/(?:channels\\/(?:\\w+\\/)?|groups\\' +
  '/([^\\/]*)\\/videos\\/|video\\/|)(\\d+)(?:|\\/\\?).*?&lt;' +
  '\\/iframe&gt;', 'g')

export {
  regexYoutube,
  regexYoutubeIframe,
  regexVimeo,
  regexVimeoIframe
}
