import { DirectUpload } from "@rails/activestorage"
import { camelizeKeys } from 'humps'
export default class Uploader {
  xhr;
  /**
   * 
   * @param {File} file 
   * @param {String} url url to upload
   * @param {Object} options could include 
   */
  constructor(file, url, options) {
    this.file = file
    this.url = url
    this.options = options
    this.directUpload = new DirectUpload(this.file, this.url, this)
  }

  upload() {
    return new Promise((resolve, reject) => {
      this.directUpload.create((error, blob) => {
        blob.tempId = this.file.tempId

        if (error) {
          this.options.$messageError?.(error, blob)
          this.options.$loadingError?.()
          reject(error)
        } else {
          this.options.$updateUploadedStatus?.(blob)
          resolve(camelizeKeys(blob))
        }
      })
    })
  }

  stopUploading() {
    this.xhr.abort?.()
    this.options.$uploadingStopped?.(this.file)
  }

  directUploadWillStoreFileWithXHR(xhr) {
    this.xhr = xhr

    xhr.upload.addEventListener("progress",
      event => this.directUploadDidProgress(event))
  }

  directUploadDidProgress(event) {
    // Use event.loaded and event.total to update the progress bar
    const percent = ((event.loaded / event.total) * 100).toFixed(1)

    // progress display
    this.options.$updateProgress?.(percent, this.file, event)
  }
}