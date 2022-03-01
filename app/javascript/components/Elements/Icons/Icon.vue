<template>
  <svg
    class="icon"
    :class="{ 'icon-spin': spin }"
    :style="{
      color: color ? color : 'transparent',
      width: getSize(),
      height: getSize()
    }"
  >
    <use :xlink:href="`#${name}`" />
  </svg>
</template>

<script>
export default {
  name: 'Icon',
  props: {
    name: {
      type: String,
      required: true
    },
    size: {
      type: String,
      default: 'normal'
    },
    color: {
      type: String,
      required: false
    },
    spin: {
      type: Boolean,
      default: false
    }
  },
  methods: {
    getSize () {
      const size = {
        small: '16px',
        normal: '26px',
        big: '36px',
        bigger: '42px'
      }
      return size[this.size]
    }
  }
}
</script>
