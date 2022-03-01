<template>
  <section class="page-blocks-holder">
    <div class="message-container">
      <div class="inner">
        <p class="message">
          {{ $i18n.t('mylives.profile_without_community') }}
        </p>
        <a @click="openAddCommunityDialog">
          {{ $i18n.t('families.new') }}
        </a>
      </div>
    </div>
  </section>
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
