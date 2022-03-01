<template>
  <DialogContent>
    <template v-slot:content>
      <v-container>
        <v-form ref="newCommunityForm" v-model="isValid">
          <v-row>
            <v-col cols="12" md="4" class="d-flex justify-md-end">
              <label class="category-avatar-edit mt-1 mr-md-4">
                <div class="category-avatar-edit__image">
                  <v-icon
                      v-if="!image || !url"
                      class="category-avatar-edit__icon"
                      color="#C4C4C4"
                  >
                    mdi-image-outline
                  </v-icon>
                  <v-img
                      v-else
                      :src="url"
                      height="156px"
                  >
                    <template v-slot:placeholder>
                      <div class="d-flex justify-center">
                        <v-progress-circular
                            class="mt-16"
                            indeterminate
                            color="#C4C4C4"
                        />
                      </div>
                    </template>
                  </v-img>
                  <v-file-input
                      ref="inputAvatar"
                      id="community-avatar"
                      class="hidden-input-file"
                      accept="image/*"
                      hide-input
                      v-model="image"
                      :disabled="isLoading"
                      @change="handleImageChange"
                  />
                </div>

                <div class="category-avatar-edit__label">
                  <template v-if="!isLoading">
                    {{ inputLabel }}
                  </template>
                  <v-progress-circular
                      v-else
                      indeterminate
                      color="#C4C4C4"
                  />
                </div>
              </label>
            </v-col>
            <v-col>
              <h4 class="f--tertiary d-inline-block mr-3">{{ $i18n.t('communities.newCommunityDialog.nameTitle') }}</h4>
              <p class="required-disclaimer d-inline-block mb-3">{{ $i18n.t('communities.newCommunityDialog.required') }}</p>
              <v-text-field
                  :placeholder="$i18n.t('communities.newCommunityDialog.namePlaceholder')"
                  v-model="community.name"
                  :rules="[rules.required]"
                  outlined
                  single-line
                  color="primary"
                  type="text"
                  height="48"
              />
              <h4 class="f--tertiary d-inline-block mr-3 mb-3">{{ $i18n.t('communities.newCommunityDialog.typeTitle') }}</h4>
              <div class="type-select mb-3">
                <div class="type-select__selection d-flex align-center" @click="toggleTypeSelect">
                  {{ community.familyType || communityTypePlaceholder }}
                  <v-icon right size="12" color="#4B4B4B" class="ml-auto">fa-chevron-down</v-icon>
                </div>
                <div v-if="isTypeSelectVisible" class="type-select__radios">
                  <v-radio-group v-model="community.selectedType">
                    <v-radio
                        v-for="(type, index) in types"
                        :key="index"
                        :label="type"
                        :value="type"
                        @change="toggleTypeSelect"
                    >
                      <template v-slot:label>
                        <span class="type-select__radio-label">{{ type }}</span>
                      </template>
                    </v-radio>
                  </v-radio-group>
                  <v-text-field
                      v-if="community.selectedType === 'Other'"
                      :placeholder="$i18n.t('communities.newCommunityDialog.typeOtherPlaceholder')"
                      v-model="community.familyType"
                      :rules="[rules.required]"
                      outlined
                      single-line
                      color="primary"
                      type="text"
                      height="48"
                  />
                </div>
              </div>
              <h4 class="f--tertiary d-inline-block mr-3 mb-3">{{ $i18n.t('communities.newCommunityDialog.mottoTitle') }}</h4>
              <v-text-field
                  :placeholder="$i18n.t('communities.newCommunityDialog.mottoPlaceholder')"
                  v-model="community.motto"
                  outlined
                  single-line
                  color="primary"
                  type="text"
                  height="48"
              />
              <h4 class="f--tertiary mb-3">{{ $i18n.t('communities.newCommunityDialog.descriptionTitle') }}</h4>
              <v-textarea
                  :placeholder="$i18n.t('communities.newCommunityDialog.descriptionPlaceholder')"
                  v-model="community.description"
                  rows="4"
                  outlined
                  class="community-description__input"
              />
            </v-col>
          </v-row>
        </v-form>
      </v-container>
    </template>
    <template v-slot:actions>
      <v-btn
        x-large
        rounded
        color="primary"
        elevation="0"
        class="ma-1 px-4"
        :disabled="isLoading || community.name.length < 3"
        @click="sendPayload()"
      >
        {{ $i18n.t('helpers.submit.family.create') }}
      </v-btn>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions} from 'vuex'
import validators from "../../utils/validators"
import { DirectUpload } from '@rails/activestorage'

const communityTypePlaceholder = 'Choose a Community Type'

export default {
  components: {
    DialogContent
  },
  data: () => ({
    isLoading: false,
    isValid: false,
    isTypeSelectVisible: false,
    image: null,
    url: null,
    communityTypePlaceholder,
    community: {
      name: '',
      selectedType: 'Community',
      familyType: 'Community',
      motto: '',
      description: '',
      cover: '',
    },
    types: ['Community', 'Family', 'Club', 'Team', 'School', 'Organization', 'Other'],
    rules: {
      required: value => validators.required(value),
    }
  }),
  computed: {
    inputLabel() {
      return (this.image)
          ? this.$i18n.t('stories.change_cover')
          : this.$i18n.t('stories.select_cover')
    }
  },
  watch: {
    'community.selectedType' () {
      if (this.community.selectedType !== 'Other') {
        this.community.familyType = this.community.selectedType
      }
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
      addNewCommunity: 'families/addNewCommunity'
    }),
    handleImageChange() {
      this.url= URL.createObjectURL(this.image)
      if (this.image) this.addAvatar(this.image)
    },
    addAvatar(image) {
      this.isLoading = true
      const upload = new DirectUpload(image, '/rails/active_storage/direct_uploads')
      upload.create((error, blob) => {
        if (error) {
          this.setError(`Direct upload failed: ${error}`)
          this.image = null
          this.url = null
          this.community.cover = null
        } else {
          this.community.cover = blob.signed_id
        }
        this.isLoading = false
      })
    },
    sendPayload() {
      this.isLoading = true
      this.addNewCommunity(this.community)
        .then((res) => {
          this.setSnackbar(this.$i18n.t('families.created'))
          this.closeDialog()
          this.$router.push('/communities/' + res.data.id + '/edit')
        })
        .catch((error) => {
          this.setError(error)
        })
        .finally(() => {
          this.isLoading = false
        })
    },
    toggleTypeSelect() {
      this.isTypeSelectVisible = !this.isTypeSelectVisible
    },
  }
}
</script>
<style lang="scss" scoped>
.required-disclaimer {
  font-weight: bold;
  font-size: 12px;
  line-height: 14px;
  color: #E95631;
}
.type-select {
  position: relative;
  &__selection {
    height: 48px;
    width: 100%;
    padding: 0 14px;
    background: #FFFFFF;
    color: $color-tertiary;
    border: 1px solid $color-medium-grey;
    border-radius: 5px;
    font-family: Lato;
    font-size: 16px;
    transition: all 0.15s linear;
    &:hover {
      border: 1px solid black;
    }
  }
  &__radios {
    position: absolute;
    z-index: 8;
    width: 100%;
    overflow-y: auto;
    overflow-x: hidden;
    contain: content;
    box-shadow: 0 5px 5px -3px rgb(0 0 0 / 20%), 0 8px 10px 1px rgb(0 0 0 / 14%), 0 3px 14px 2px rgb(0 0 0 / 12%);
    background: $color-dark-white;
    border: 1px solid $color-medium-grey;
    box-sizing: border-box;
    border-radius: 6px;
    padding: 0 24px;
  }
  &__radio-label {
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;
    color: $color-tertiary;
  }
}
.category-avatar-edit {
  display: block;
  background: $color-dark-white;
  border: 2px dotted #D0D0D0;
  box-sizing: border-box;
  border-radius: 5px;
  max-width: 208px;
  max-height: 208px;
  width: 100%;
  cursor: pointer;
  &:hover {
    background: $color-medium-grey;
  }
  &__image {
    position: relative;
    min-height: 156px;
    display: flex;
    justify-content: center;
    align-content: center;
  }
  &__label {
    background: #FDFDFD;
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
.community-description {
  &__input {
    &::v-deep .v-text-field__slot textarea::placeholder {
      font-size: 16px;
      line-height: 19px;
      color: #C4C4C4;
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
</style>
