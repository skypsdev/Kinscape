<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        <div class="subtitle-2">
          {{ $i18n.t('placeholders.section.remove') }}
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
          @click="closeDialog"
        >
          {{ $i18n.t('placeholders.section.remove_deny') }}
        </v-btn>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1"
          @click="deleteSelectedChapter"
        >
          {{ $i18n.t('placeholders.section.remove_approve') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions, mapState} from 'vuex'
export default {
  components: {
    DialogContent
  },
  computed: {
    ...mapState({
      section: state => state.layout.dialog.data.section,
      viewType: state => state.layout.dialog.data.viewType
    })
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
      deleteChapter: 'stories/deleteChapter',
      deleteCommunityChapter: 'families/deleteChapter',
      deleteMemberChapter: 'members/deleteChapter'
    }),
    deleteSelectedChapter() {
      if (this.viewType === 'community') {
        this.deleteCommunityChapter(this.section)
      } else if (this.viewType === 'member') {
        this.deleteMemberChapter(this.section)
      } else {
        this.deleteChapter(this.section)
      }
      this.closeDialog()
    }
  }
}
</script>
