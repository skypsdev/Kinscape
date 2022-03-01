<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-12 mx-10">
        <h4 class="text-center">{{ $i18n.t("stories.share_modal.with_family.ownership_option") }}</h4>
        <v-container class="mt-9">
          <v-card
              class="share-story-dialog__card"
              flat
              @click="sendPublication('community')"
          >
            <v-row class="mb-4">
              <v-col cols="12" md="4" class="d-flex justify-center">
                <v-img
                    max-height="200"
                    contain
                    :src="require('../../assets/images/ownership_shared.svg')"
                />
              </v-col>
              <v-col cols="12" md="8" class="d-flex flex-column justify-center">
                <h4 class="mt-5">
                  {{ $i18n.t("stories.share_modal.with_family.shared_title") }}
                </h4>
                <p class="mt-2">
                  {{ $i18n.t("stories.share_modal.with_family.shared_description") }}
                </p>
              </v-col>
            </v-row>
          </v-card>
          <v-divider/>
          <v-card
              class="share-story-dialog__card"
              flat
              @click="sendPublication('shared')"
          >
            <v-row class="mt-4 mb-2 mx-14">
              <v-col cols="12" md="4" class="d-flex justify-center">
                <v-img
                    max-height="200"
                    contain
                    :src="require('../../assets/images/ownership_private.svg')"
                />
              </v-col>
              <v-col cols="12" md="8" class="d-flex flex-column justify-center">
                <h4 class="mt-5">
                  {{ $i18n.t("stories.share_modal.with_family.private_title") }}
                </h4>
                <p class="mt-2">
                  {{ $i18n.t("stories.share_modal.with_family.private_description") }}
                </p>
              </v-col>
            </v-row>
          </v-card>
        </v-container>
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
  data: () => ({
    loading: false,
    search: '',
    selected: []
  }),
  computed:{
    ...mapState({
      story: state => state.stories.story,
      dialog: state => state.layout.dialog
    }),
  },
  created() {
    this.dialog.size = 'big'
    this.publication = this.dialog.data
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      createPublication: 'stories/createPublication'
    }),
    async sendPublication (type) {
      if (!this.loading) {
        this.loading = true
        try {
          this.publication.shareType = type
          await this.createPublication({ publication: this.publication, storyId: this.story.id })
          this.setSnackbar(this.$i18n.t('stories.publish_success'))
          this.loading = false
          this.$router.go()
        } finally {
          this.loading = false
          this.closeDialog()
        }
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.share-story-dialog {
  &__card {
    border-radius: 5px;
    &:hover {
      background: $color-lightest_purple;
    }
  }
}
</style>
