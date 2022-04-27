<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        <div v-if="publicationId" class="subtitle-2">
          {{ $i18n.t('stories.delete_confirmation_unshare') }}
        </div>
        <div v-else class="subtitle-2">
          {{ $i18n.t('stories.delete_confirmation_delete') }}
        </div>
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
          @click="closeDialog()"
        >
         {{ $i18n.t('confirmation_dialog.cancel') }}
        </v-btn>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1"
          :disabled="isLoading"
          @click="publicationId ? unShareItem() : deleteStory()"
        >
          {{ $i18n.t('confirmation_dialog.confirm') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions, mapState} from 'vuex'
import { PublicationsRepository, StoriesRepository } from "../../repositories";
export default {
  components: {
    DialogContent
  },
  data: () => ({
    isLoading: false
  }),
  computed: {
    ...mapState({
      story: state => state.stories.story,
      currentUser: state => state.core.user,
      dialogParams: state => state.layout.dialog.data
    }),
    isAuthor () {
      return this.currentUser.id.toString() === this.story.userId?.toString()
    },
    publicationId () {
      return this.dialogParams.publicationId
    },
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar'
    }),
    async deleteStory () {
      this.isLoading = true
      try {
        await StoriesRepository.deleteStory(this.story.publication.id)
        this.closeDialog()
        this.setSnackbar(this.$i18n.t(
          'stories.deleted',
          { title: this.story.title }
        ))
        await this.$router.push({ name: 'stories' })
      } catch (error) {
        console.error(error)
        this.setSnackbar({
          color: 'error',
          messages: [this.$i18n.t('flashes.alert.unauthorized')]
        })
      } finally {
        this.isLoading = false
      }
    },
    async unShareItem () {
      try {
        await PublicationsRepository.deletePublication(this.publicationId)
        this.closeDialog()
        this.setSnackbar(this.$i18n.t('stories.unpublished'))
        await this.$router.push({ name: 'stories' })
      } catch (error) {
        this.setError(error)
      }
    },
  }
}
</script>
