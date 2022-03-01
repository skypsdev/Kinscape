export const globalMixin = {
  methods: {
    backgroundImage (url) {
      if (url) return { 'background-image': `url(${url})` }
    }
  }
}
