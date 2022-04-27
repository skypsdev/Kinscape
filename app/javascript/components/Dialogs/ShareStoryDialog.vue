<template>
  <DialogContent>
    <template v-slot:content>
      <div class="pa-12">
        <h4>{{ $i18n.t("stories.share_modal.with_family.label") }}</h4>
        <p class="mt-2">
          {{ $i18n.t("stories.share_modal.with_family.hint") }}
        </p>
        <v-row class="mt-2">
          <v-col cols="12" md="4">
            <v-text-field
              ref="search"
              v-model="search"
              full-width
              hide-details
              label="Search"
              single-line
              outlined
              rounded
              prepend-inner-icon="mdi-magnify"
            ></v-text-field>
          </v-col>
        </v-row>
        <ToggleSelect
          :items="filteredCommunities"
          v-model="selected"
          :search="search"
        />
        <v-row>
          <PublishDatePicker
            @changeDate="addPublishDate"
            @validate="setValidation"
          />
        </v-row>
      </div>
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1"
          :disabled="!isValid || !selected.length"
          @click="goToNextStep"
        >
          {{ $i18n.t("stories.share_modal.button.share") }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import PublishDatePicker from "@/components/Elements/Forms/PublishDatePicker"
import ToggleSelect from "@/components/Elements/Forms/ToggleSelect"

export default {
  components: {
    ToggleSelect,
    PublishDatePicker,
    DialogContent
  },
  data: () => ({
    isValid: true,
    loading: false,
    publication: {},
    publishInFuture: false,
    search: '',
    selected: [],
  }),
  computed: {
    ...mapState({
      dialog: state => state.layout.dialog,
      story: state => state.stories.story,
      sharableFamilies: state => state.families.sharableFamilies,
    }),
    filteredCommunities() {
      const search = this.search.toLowerCase()
      let result = []

      if (!search) {
        result = this.sharableFamilies
      } else {
        result = this.sharableFamilies.filter(item => {
          const text = item.attributes.name.toLowerCase()

          return text.indexOf(search) > -1
        })
      }
      return result.map(item => {
        return {
          id: item.id,
          image: item.attributes.coverUrl,
          ...item.attributes,
        }
      })
    },
  },
  watch: {
    selected() {
      this.search = ''
    },
  },
  created() {
    this.getSharableFamilies(this.story.publication.id)
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',

    }),
    ...mapActions('families', ['getSharableFamilies']),
    addPublishDate(form) {
      if (form.isVisible) {
        this.publication.publishOn = { ...form }
      }
    },
    async goToNextStep() {
      try {
        this.publication.familiesIds = this.selected.map(community => community.id)
        await this.closeDialog()
        this.setDialog({
          component: 'ShareTypeStoryDialog',
          title: this.$i18n.t('stories.share_modal.with_family.share_type_title'),
          data: this.publication
        })
      } catch (error) {
        this.setError(error)
      }
    },
    setValidation(validation) {
      this.isValid = !validation.error
    }
  }
}
</script>
