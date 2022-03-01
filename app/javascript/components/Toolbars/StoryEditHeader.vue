<template>
  <v-row>
    <v-col class="d-flex flex-row align-center">
      <StoryBreadcrumbs/>
    </v-col>
    <v-col class="d-flex flex-row align-center justify-end fill-height">
      <v-btn
        class="ml-1"
        rounded
        outlined
        color="primary"
        elevation="0"
        :title="$i18n.t('stories.preview_title')"
        @click="doneEditing"
      >
        {{ story.isChanged ? $i18n.t('stories.preview') : $i18n.t("stories.cancel") }}
      </v-btn>
    </v-col>
  </v-row>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import StoryBreadcrumbs from './Stories/StoryBreadcrumbs'

export default {
  components: {
    StoryBreadcrumbs,
  },
  computed: {
    ...mapState({
      story: state => state.stories.story
    })
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    doneEditing () {
      if (this.story.isPublished && this.story.isChanged && !this.story.isTimeCapsule) {
        this.setDialog({
          title: this.$i18n.t('stories.notifications.title'),
          component: 'NotifyAboutChangesDialog'
        })
      } else {
        this.$router.push({
          name: 'showStory',
          params: { id: this.story.publication.id }
        })
      }
    }
  }
}
</script>
