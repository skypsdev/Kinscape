<template>
  <v-row>
    <v-col class="d-flex flex-row align-center">
      <StoryBreadcrumbs/>
    </v-col>
    <v-col class="d-flex flex-row align-center justify-end fill-height">
      <SharedInMenu/>
      <v-btn
          v-if="canCurrentUserEdit"
          class="ml-1"
          rounded
          outlined
          color="primary"
          elevation="0"
          :title="$i18n.t('stories.action_button.edit_title')"
          :to="{name: 'editStory', params: { id: story.publication.id }}"
      >
        <v-icon left>mdi-pencil-outline</v-icon>
        {{ $i18n.t('stories.action_button.edit') }}
      </v-btn>
      <StoryToolbar/>
    </v-col>
  </v-row>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import StoryToolbar from './Stories/StoryToolbar'
import StoryBreadcrumbs from './Stories/StoryBreadcrumbs'
import SharedInMenu from "./Stories/SharedInMenu";

export default {
  components: {
    SharedInMenu,
    StoryToolbar,
    StoryBreadcrumbs
  },
  computed: {
    ...mapState({
      story: state => state.stories.story,
      currentUser: state => state.core.user
    }),
    canCurrentUserEdit() {
      return this.$possible('manage', 'Publication', { story: { userId: this.story.userId } })
    },
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    openShareDialog() {
      let dialog = {
        component: 'ShareStoryDialog',
        title: this.$i18n.t('stories.share_modal.with_family.title'),
        size: 'big'
      }
      if (this.story.isPublished) {
        dialog = {
          component: 'UnshareStoryDialog',
          title: this.$i18n.t('confirmation_dialog.title')
        }
      }
      this.setDialog(dialog)
    }
  }
}
</script>
