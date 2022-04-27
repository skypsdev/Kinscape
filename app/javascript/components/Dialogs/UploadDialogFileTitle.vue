<template>
  <div class="d-flex align-center">
    <v-text-field
      v-if="editMode"
      class="dragzone__name-field"
      v-model="name"
      outlined
      single-line
      color="primary"
      type="text"
      height="40"
    />
    <h4 v-else class="dragzone-wrapper__title" :title="editMode && name">
      {{ name }}
    </h4>

    <slot></slot>
  </div>
</template>

<script>
import { debounce as _debounce } from 'lodash'
import { splitExtension } from '@/utils/common'
export default {
  props: {
    fileName: {
      type: String,
      default: '',
      required: true
    },
    editMode: {
      type: Boolean,
      default: false,
      required: true
    }
  },
  data() {
    return {
      nameCopy: ''
    }
  },

  computed: {
    extension() {
      return splitExtension(this.fileName)[1]
    },
    name: {
      get() {
        let { fileName } = this
        // should return full name if  is not in edit mode
        if (!this.editMode) return fileName

        // pop extension in edit mode
        const nameArr = fileName.split('.')
        nameArr.pop()
        return nameArr.join('.')
      },
      set: _debounce(function (value) {
        // prevent updating if no difference
        if (this.nameCopy.trim() == value.trim()) return


        value = `${value}.${this.extension}`

        this.$emit('update:file-name', value)
      }, 300)
    }
  },
  watch: {
    //usage:
    //compare for changes to decide about update
    editMode(bool) {
      if (bool) {
        this.nameCopy = this.name
      } else {
        this.nameCopy = ''
      }
    }
  },
}
</script>

<style>
</style>