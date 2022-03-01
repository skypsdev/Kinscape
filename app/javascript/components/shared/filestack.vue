<template>
  <div @click.prevent="onClickPick">
    <slot />
  </div>
</template>

<script>
const filestack = require('filestack-js')
export default {
  props: {
    file: {
      type: Object,
      default: null
    },
    link: {
      type: Boolean,
      default: false
    },
    mode: {
      type: String,
      default: 'pick'
    },
    options: {
      type: Object,
      default () {
        return {}
      }
    },
    security: {
      type: Object,
      default: null
    },
    cname: {
      type: String,
      default: null
    },
    maxFiles: {
      type: Number,
      default: 1000
    }
  },
  computed: {
    clientOptions () {
      return {
        cname: this.cname,
        security: this.security,
        sessionCache: true
      }
    }
  },
  mounted () {
    const source = new URL(location.href).searchParams.get('source')

    if (source) {
      this.onClickPick()

      var sourceId = 0

      if (source === 'device') {
        sourceId = 0
      } else if (source === 'facebook') {
        sourceId = 3
      } else if (source === 'instagram') {
        sourceId = 4
      } else if (source === 'dropbox') {
        sourceId = 6
      }

      setTimeout(function () {
        document.getElementsByClassName('fsp-source-list__item')[sourceId]
          .click()
      }, 2000)
    }
  },
  methods: {
    onSuccess (result) {
      this.$emit('success', result)
    },
    onError (err) {
      this.$emit('error', err)
    },
    onClickPick () {
      this.initClient(
        this.mode,
        this.options,
        this.file,
        this.security,
        this.cname
      )
        .then((result) => this.onSuccess(result))
        .catch((err) => this.onError(err))
    },
    initClient (mode, options, file, security) {
      const url = options.url
      const handle = options.handle
      this.client = filestack.init(
        this.$filestackKey, this.clientOptions
      )
      const ops = Object.assign({}, options)
      delete ops.handle
      delete ops.url
      ops.maxFiles = this.maxFiles
      if (mode === 'transform') {
        return new Promise((resolve, reject) => {
          try {
            resolve(this.client.transform(url, ops))
          } catch (err) {
            reject(err)
          }
        })
      } else if (mode === 'retrieve') {
        return this.client.retrieve(handle, ops)
      } else if (mode === 'metadata') {
        return this.client.metadata(handle, ops)
      } else if (mode === 'storeUrl') {
        return this.client.storeURL(url, ops)
      } else if (mode === 'upload') {
        return this.client.upload(file, ops)
      } else if (mode === 'remove') {
        return this.client.remove(handle, security)
      }
      return this.client.picker(ops).open()
    },
    setSecurity (security) {
      this.client.setSecurity(security)
    }
  }
}
</script>

<style>
  .fsp-url-source__input {
    margin: auto !important;
  }

  .fsp-button,
  .fsp-button--authgoogle {
    width: auto !important;
  }
</style>
