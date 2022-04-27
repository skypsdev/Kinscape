<script>
export default {
  computed: {
    isMobile() {
      //https://vuejs.org/v2/style-guide/#Private-property-names-essential
      // https://github.com/vuejs/vue/issues/8432
      return ['xs', 'sm'].includes(this.$vuetify.breakpoint.name)
    },
    isAboveLg() {
      return ['lg', 'xl'].includes(this.$vuetify.breakpoint.name)
    }
  }
}
</script>
