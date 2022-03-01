<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        <div class="subtitle-2">
          {{ $i18n.t('stories.delete_confirmation') }}
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
          @click="deleteStory()"
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
import {StoriesRepository} from "../../repositories";
export default {
  components: {
    DialogContent
  },
  data: () => ({
    isLoading: false
  }),
  computed: {
    ...mapState({
      story: state => state.stories.story
    })
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar'
    }),
    async deleteStory () {
      this.isLoading = true
      try {
        await StoriesRepository.deleteStory(this.story.id)
        this.closeDialog()
        this.setSnackbar(this.$i18n.t(
          'stories.deleted',
          { title: this.story.title }
        ))
        this.$router.push({ name: 'stories' })
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
  }
}
</script>
