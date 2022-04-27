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
      <v-list-item v-if="canManage" @click="duplicateStory(story.publication.id)">
        <v-list-item-title>
          {{ $i18n.t('stories.action_button.copy') }}
        </v-list-item-title>
      </v-list-item>
      <v-list-item :href="`/publications/${story.publication.id}/download`">
        <v-list-item-title>
          {{ $i18n.t('stories.files.download') }}
        </v-list-item-title>
      </v-list-item>
      <v-divider></v-divider>
      <v-list-item v-if="canManage" @click="confirmDeleteStory">
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
      story: state => state.stories.story,
      currentUser: state => state.core.user
    }),
    canManage () {
      return this.$possible('manage', 'Publication', { story: { userId: parseInt(this.story.userId) }, familyId: this.story.publication?.attributes?.familyId  })
    },
    isConnector () {
      return this.currentUser.id.toString() !== this.story.community?.connectorId?.toString()
    }
  },
  methods: {
    ...mapActions({
      setSnackbar: 'layout/setSnackbar',
      setDialog: 'layout/setDialog'
    }),
    printWindow () {
      window.print()
    },
    confirmDeleteStory () {
      var publicationId = this.isConnector ? this.story.publication?.id : null
      this.setDialog({
        title: this.$i18n.t('stories.delete_title'),
        component: 'StoryDeleteDialog',
        data: {
          publicationId
        }
      })
    },
    async duplicateStory (id) {
      try {
        const response = await StoriesRepository.duplicateStory(id)
        this.$router.push({
          name: 'showStory',
          params: { id: response.data.relationships.publications.data[0].id }
        })

        this.setSnackbar(this.$i18n.t('stories.copied'))
      } catch (error) {
        console.error(error)
      }
    },
  }
}
</script>
