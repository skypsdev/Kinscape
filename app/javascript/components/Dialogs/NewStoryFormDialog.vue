<template>
  <DialogContent>
    <template v-slot:content>
      <v-container>
        <v-form ref="newStoryForm" v-model="isValid">
          <v-row>
            <v-col cols="12" md="4" class="d-flex justify-md-end">
              <UploadDialog
                :configuration="uploadDialogConfiguration"
                :active.sync="uploadDialogConfiguration.active"
              >
                <template #default>
                  <UploadDialogContent
                    :configuration="uploadDialogContentConfiguration"
                  />
                </template>

                <template #activator="{ attrs, on }">
                  <label
                    class="story-avatar-edit mt-14 mr-md-4"
                    v-bind="attrs"
                    v-on="on"
                  >
                    <div class="story-avatar-edit__image">
                      <v-icon
                        v-if="!coverUrl"
                        class="story-avatar-edit__icon"
                        color="medium_grey"
                      >
                        mdi-image-outline
                      </v-icon>
                      <v-img v-else :src="coverUrl" height="156px">
                        <template v-slot:placeholder>
                          <div class="d-flex justify-center">
                            <v-progress-circular
                              class="mt-16"
                              indeterminate
                              color="medium_grey"
                            />
                          </div>
                        </template>
                      </v-img>
                    </div>
                    <div class="story-avatar-edit__label">
                      <template v-if="!isLoading">
                        {{ inputLabel }}
                      </template>
                      <v-progress-circular
                        v-else
                        indeterminate
                        color="medium_grey"
                      />
                    </div>
                  </label>
                </template>
              </UploadDialog>
            </v-col>
            <v-col>
              <h4 class="new-story__label d-inline-block mt-10 mr-3">
                {{ $i18n.t("stories.newStoryDialog.storyTitleLabel") }}
              </h4>
              <p class="new-story__label--required d-inline-block mb-3">
                * {{ $i18n.t("stories.newStoryDialog.required") }}
              </p>
              <v-text-field
                class="new-story__input"
                :placeholder="
                  $i18n.t('stories.newStoryDialog.storyTitlePlaceholder')
                "
                v-model="form.title"
                :rules="[rules.required]"
                outlined
                single-line
                color="primary"
                type="text"
              />
              <h4
                class="new-story__label mb-3"
                v-text="$i18n.t('placeholders.story.categories')"
              />
              <Combobox ref="Categories" :items="allCategories" class="mb-6" />
              <h4 class="new-story__label mb-3">
                {{ $i18n.t("stories.newStoryDialog.storyDescriptionLabel") }}
              </h4>
              <v-textarea
                :placeholder="
                  $i18n.t('stories.newStoryDialog.storyDescriptionPlaceholder')
                "
                v-model="form.description"
                rows="4"
                outlined
              />
              <h4 class="new-story__label mb-3">
                {{ $i18n.t("stories.newStoryDialog.storyDateLabel") }}
              </h4>
              <DateRangePicker ref="DateRangPicker" />
            </v-col>
          </v-row>
        </v-form>
      </v-container>
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1 new-story-cvr-btn"
          :disabled="!isValid || isLoading"
          @click="createStoryThenRedirect"
        >
          {{ $i18n.t("stories.newStoryDialog.button") }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import { mapActions, mapState } from 'vuex'
import { decamelizeKeys } from 'humps'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import DateRangePicker from '@/components/Elements/Forms/DateRangePicker'
import Combobox from '@/components/Elements/Forms/Combobox'
import BaseDialog from '@/components/Layout/Dialog/Dialog'
import UploadDialog from '@/components/Dialogs/UploadDialog'

import validators from '@/utils/validators'
import { StoriesRepository } from '@/repositories'

export default {
  components: {
    DateRangePicker,
    DialogContent,
    Combobox,
    UploadDialog: BaseDialog,
    UploadDialogContent: UploadDialog
  },
  data() {
    return {
      uploadDialogConfiguration: {
        customClass: 'upload-dialog',
        active: false,
        persistent: true
      },
      uploadDialogContentConfiguration: {
        closeGlobalDialog: false,
        closeDialog: this.closeUploadDialog,
        data: { callback: this.handleImageChange }
      },
      coverUrl: '',
      isValid: false,
      isLoading: false,
      form: {
        title: '',
        description: '',
        cover: '',
        categories: []
      },
    }
  },
  computed: {
    ...mapState({
      story: store => store.stories.story,
      allCategories: store => store.stories.allCategories
    }),
    rules() {
      return {
        required: value => validators.required(value),
        isAfterStartDate: value => new Date(value) > new Date(this.story.dateAsText)
          || this.$i18n.t('errors.attributes.must_be_after_start')
      }
    },
    inputLabel() {
      return (this.form.cover)
        ? this.$i18n.t('stories.change_cover')
        : this.$i18n.t('stories.select_cover')
    }
  },
  created() {
    this.getCategories()
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError',
      createNewStory: 'stories/createNewStory',
      setDialog: 'layout/setDialog',
      closeDialog: 'layout/closeDialog',
      getCategories: 'stories/getCategories'
    }),
    async createStoryThenRedirect() {
      const response = await StoriesRepository.createStory({
        story: decamelizeKeys({
          ...this.form,
          ...this.$refs.DateRangPicker.form,
          categories: this.$refs.Categories.selectedItems
        })
      })
      const publicationId = response.data.relationships.publications.data[0].id
      await this.$router.push('/stories/' + publicationId + '/edit')
      this.closeDialog()
    },
    handleImageChange([image], [blob]) {
      this.$set(this.form, 'cover', image.signedId)
      this.coverUrl = URL.createObjectURL(blob)
    },
    closeUploadDialog() {
      this.$set(this.uploadDialogConfiguration, 'active', false)
    }
  }
}
</script>
<style lang="scss" scoped>
.new-story {
  &__input::v-deep.v-text-field {
    font-size: 18px;
    color: $color-tertiary;
    .v-input__control {
      min-height: 48px !important;
    }
    .v-input__slot {
      min-height: 48px !important;
    }
    .v-label {
      top: 6px !important;
    }
  }
  &__label {
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-tertiary;
    &--required {
      font-weight: bold;
      font-size: 12px;
      line-height: 14px;
      color: $color-required;
    }
  }
}

::v-deep .v-label {
  font-family: Lato;
  font-style: normal;
  font-weight: bold;
  font-size: 12px;
  line-height: 14px;
}
.story-avatar-edit {
  display: block;
  background: $color-dark-white;
  border: 2px dotted $gray1;
  box-sizing: border-box;
  border-radius: 5px;
  max-width: 208px;
  max-height: 208px;
  width: 100%;
  cursor: pointer;
  &:hover {
    background: $color-light-grey;
  }
  &__image {
    position: relative;
    min-height: 156px;
    display: flex;
    justify-content: center;
    align-content: center;
  }
  &__label {
    background: $white1;
    border-radius: 0px 0px 2px 2px;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 48px;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 17px;
    line-height: 24px;
    text-align: center;
    color: $color-text;
  }
  &__icon {
    font-size: 70px !important;
  }
  .hidden-input-file {
    position: absolute;
    z-index: -1;
    .v-icon {
      display: none;
    }
  }
}
</style>
