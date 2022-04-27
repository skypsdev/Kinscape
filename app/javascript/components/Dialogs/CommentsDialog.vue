<template>
  <DialogContent>
    <template v-slot:content>
      <Comments
        commentable-type="Publication"
        :commentable-id="dialog.commentableId"
        :parent-id="dialog.parentId"
        parent-type="Publication"
      />
    </template>
  </DialogContent>
</template>

<script>
import {mapState} from 'vuex'
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import Comments from '../Elements/Comments'

export default {
  components: {
    DialogContent,
    Comments
  },
  computed: {
    ...mapState({
      publicationId: store => store.stories.story.publication.id,
      dialog: state => state.layout.dialog.data
    })
  }
}
</script>
