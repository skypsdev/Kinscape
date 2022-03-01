<template>
  <v-btn
    rounded
    color="primary"
    elevation="0"
    title="Start a New Community"
    class="add-community-button"
    @click="openAddCommunityDialog"
  >
    {{ $i18n.t('families.new') }}
  </v-btn>
</template>

<script>
import {mapActions} from 'vuex'

export default {
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    openAddCommunityDialog() {
      this.setDialog({
        title: this.$i18n.t('families.new'),
        component: 'AddCommunityDialog'
      })
    }
  }
}
</script>
