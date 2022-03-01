<script>
export default {
  data: () => ({
    mobileBreakpoints: ['xs', 'sm']
  }),
  computed: {
    isMobile() {
      return ['xs', 'sm'].includes(this.$vuetify.breakpoint.name)
    }
  }
}
</script>
