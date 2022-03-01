<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        {{ $i18n.t('stories.unshare.confirmation') }}
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
          @click="unshareStory"
        >
          {{ $i18n.t('confirmation_dialog.confirm')}}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions, mapState} from 'vuex'
import {PublicationsRepository} from "../../repositories";
export default {
  components: {
    DialogContent
  },
  computed:{
    ...mapState({
      story: state => state.stories.story
    })
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError'
    }),
    async unshareStory () {
      try {
        await PublicationsRepository.deletePublication(
          this.story.id, this.story.publicationId
        )
        if (this.story.isTimeCapsule) {
          this.setSnackbar(this.$i18n.t('stories.time_capsule_disabled'))
        } else {
          this.setSnackbar(this.$i18n.t('stories.unpublished'))
        }
        this.$router.go()
      } catch (error) {
        this.setError(error)
      } finally {
        this.closeDialog()
      }
    }
  }
}
</script>
