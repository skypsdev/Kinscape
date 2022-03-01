<template>
  <MountingPortal mount-to="#vue-saving-status">
    <div class="saving-status">
      {{ statusMessage }}
    </div>
  </MountingPortal>
</template>

<script>
export default {
  props: {
    status: {
      type: String,
      required: true
    }
  },
  computed: {
    statusMessage () {
      switch (this.status) {
        case 'initial': return ''
        case 'started': return this.$i18n.t('persistence_status.started')
        case 'finished': return this.$i18n.t('persistence_status.finished')
        case 'failed': return this.$i18n.t('persistence_status.failed')
        default: return ''
      }
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
