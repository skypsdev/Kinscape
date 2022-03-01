<template>
  <section>
    <v-btn
        v-if="isCommunities"
        text
        class="app-bar-button app-bar-button--new-story"
        title="Start a New Community"
        @click="openAddCommunityDialog"
    >
      <v-icon>mdi-plus-circle-outline</v-icon>
      <div>
        {{ $i18n.t('families.new') }}
      </div>
    </v-btn>
    <v-btn
        v-else
        text
        class="app-bar-button app-bar-button--new-story"
        :title="$i18n.t('stories.new')"
        @click="openNewStoryDialog"
    >
      <v-icon>mdi-plus-circle-outline</v-icon>
      <div>{{ $i18n.t('stories.new') }}</div>
    </v-btn>
  </section>
</template>
<script>
import { mapActions } from 'vuex'

export default {
  computed: {
    isCommunities() {
      return this.$route.name === 'communities';
    },
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    openNewStoryDialog() {
      this.setDialog({
        component: 'NewStoryFormDialog',
        title: this.$i18n.t('stories.newStoryDialog.title'),
        size: 'big'
      })
    },
    openAddCommunityDialog() {
      this.setDialog({
        title: this.$i18n.t('families.new'),
        component: 'AddCommunityDialog'
      })
    }
  }
}
</script>
