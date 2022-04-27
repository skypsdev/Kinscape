<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        {{ $i18n.t("stories.notifications.text") }}
      </div>

    </template>
    <template v-slot:actions>
      <div>
        <v-btn
            x-large
            rounded
            outlined
            color="primary"
            elevation="0"
            class="ma-1"
            @click="closeEditMode"
        >
          {{ $i18n.t("stories.notifications.button.go_to_story") }}
        </v-btn>
        <v-btn
            x-large
            rounded
            color="primary"
            elevation="0"
            class="ma-1"
            @click="sendNotification"
        >
          {{ $i18n.t("stories.notifications.button.send") }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions, mapState} from 'vuex'
import {StoriesRepository} from '../../repositories'

export default {
  components: {
    DialogContent
  },
  computed: {
    ...mapState({
      story: state => state.stories.story,
      activeChapter: state => state.stories.activeChapter
    })
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError'
    }),
    closeEditMode() {
      this.$router.push({
        name: 'showStory',
        params: { id: this.story.publication.id }
      })
      this.closeDialog()
    },
    async sendNotification () {
      var params = {
        changed_generic: this.story.isChanged,
      }
      if (this.story.chapterAdded.length > 0) {
        params.added_chapter = this.story.chapterAdded
      }
      try {
        await StoriesRepository.notifyContribution(this.story.publication.id, {changed_attr: params})
        this.setSnackbar(this.$i18n.t('stories.notification'))
      } catch (error) {
        this.setError(error)
      } finally {
        this.closeEditMode()
      }
    }
  }
}
</script>
