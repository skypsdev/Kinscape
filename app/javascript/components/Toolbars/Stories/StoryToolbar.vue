<template>
  <v-menu offset-y>
    <template v-slot:activator="{ on, attrs }">
      <v-btn
        class="mx-2"
        fab
        x-small
        outlined
        color="primary"
        v-bind="attrs"
        v-on="on"
      >
        <v-icon>mdi-dots-horizontal</v-icon>
      </v-btn>
    </template>
    <v-list dense>
      <v-list-item @click="duplicateStory(story.id)">
        <v-list-item-title>
          {{ $i18n.t('stories.action_button.copy') }}
        </v-list-item-title>
      </v-list-item>
<!--      <v-list-item :href="`/stories/${story.id}/download`">
        <v-list-item-title>
          {{ $i18n.t('stories.files.download') }}
        </v-list-item-title>
      </v-list-item>-->
      <v-list-item @click="printWindow()">
        <v-list-item-title>Print</v-list-item-title>
      </v-list-item>
      <v-divider></v-divider>
      <v-list-item @click="confirmDeleteStory">
        <v-list-item-title>
          {{ $i18n.t('stories.action_button.delete') }}
        </v-list-item-title>
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import {StoriesRepository} from "../../../repositories";

export default {
  computed: {
    ...mapState({
      story: state => state.stories.story
    })
  },
  methods: {
    ...mapActions({
      setStoryFamily: 'stories/setStoryFamily',
      setSnackbar: 'layout/setSnackbar',
      setDialog: 'layout/setDialog'
    }),
    printWindow () {
      window.print()
    },
    confirmDeleteStory () {
      this.setDialog({
        title: this.$i18n.t('confirmation_dialog.title'),
        component: 'StoryDeleteDialog'
      })
    },
    async duplicateStory (storyId) {
      try {
        const response = await StoriesRepository.duplicateStory(storyId)
  
        this.$router.push({
          name: 'editStory',
          params: { id: response.data.id }
        })
      
        this.setSnackbar(this.$i18n.t('stories.copied'))
      } catch (error) {
        console.error(error)
      }
    },
  }
}
</script>
