import Vue from 'vue'
const allowedFileTypes = [
  'text/plain',
  'application/pdf',
  'application/zip',
  'application/rar',
  'image/jpeg',
  'image/png',
  'image/gif',
  'audio/mp3',
  'audio/mpeg',
  'video/mp4',
  'video/mpeg',
  'video/quicktime',
  'application/msword',
  'application/vnd.ms-excel',
  'application/vnd.ms-powerpoint',
  'application/vnd.openxmlformats-officedocument.' +
  'wordprocessingml.document',
  'application/vnd.openxmlformats-officedocument.' +
  'spreadsheetml.sheet',
  'application/vnd.openxmlformats-officedocument.' +
  'presentationml.presentation'
]

Object.freeze(allowedFileTypes)

export default () => {
    Vue.prototype.$directUploadAllowedFileTypes = allowedFileTypes
}
