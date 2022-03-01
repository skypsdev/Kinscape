<template>
  <DialogContent>
    <template v-slot:content>
      <v-container>
        <v-form ref="newProfileForm" v-model="isValid">
          <v-row>
            <v-col cols="12" md="4" class="mt-16 d-flex justify-md-end">
              <label class="avatar-edit mt-1 mr-md-4">
                <div class="avatar-edit__image">
                  <v-icon
                      v-if="!image || !url"
                      class="avatar-edit__icon pb-10"
                      color="#C4C4C4"
                  >
                    mdi-account-outline
                  </v-icon>
                  <v-avatar
                      height="208px"
                      width="208px"
                      v-else
                  >
                    <v-img
                        :src="url"
                        height="208px"
                        width="208px"
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
                  </v-avatar>
                  <v-file-input
                      ref="inputAvatar"
                      id="avatar"
                      class="hidden-input-file"
                      accept="image/*"
                      hide-input
                      v-model="image"
                      :disabled="isLoading"
                      @change="handleImageChange"
                  />
                </div>

                <div class="avatar-edit__label">
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
            <v-col class="mt-16">
              <p class="profile-setup__description">
                {{ $i18n.t('communities.add_offline_member.explainer') }}
              </p>
              <h4 class="profile-setup__heading f--tertiary d-inline-block mr-3">{{ $i18n.t('welcome.name_label') }}</h4>
              <p class="required-disclaimer d-inline-block mb-3">{{ $i18n.t('communities.newCommunityDialog.required') }}</p>
              <v-row>
                <v-col cols="12" md="11">
                  <v-text-field
                      :placeholder="$i18n.t('communities.add_offline_member.name_placeholder')"
                      v-model="profile.nickname"
                      :rules="[rules.required]"
                      outlined
                      single-line
                      color="primary"
                      type="text"
                      height="48"
                  />
                </v-col>
              </v-row>
              <h4 class="profile-setup__heading f--tertiary d-inline-block mr-3">
                {{ $i18n.t('communities.add_offline_member.description') }}
              </h4>
              <v-row>
                <v-col cols="12" md="11">
                  <v-text-field
                      :placeholder="$i18n.t('communities.add_offline_member.description_placeholder')"
                      v-model="profile.description"
                      :rules="[rules.required]"
                      outlined
                      single-line
                      color="primary"
                      type="text"
                      height="48"
                  />
                </v-col>
              </v-row>
              <h4 class="profile-setup__heading f--tertiary d-inline-block mr-3 mb-3">{{ $i18n.t('welcome.info_label') }}</h4>
              <v-row>
                <v-col cols="12" md="5">
                  <v-text-field
                      prepend-icon="mdi-map-marker-outline"
                      :placeholder="$i18n.t('communities.add_offline_member.birth_place_placeholder')"
                      v-model="profile.profileAttrs.placeBirth"
                      outlined
                      single-line
                      color="primary"
                      type="text"
                      height="30"
                  />
                </v-col>
                <v-col cols="12" md="5" offset-md="1">
                  <DatePicker v-model="profile.profileAttrs.birthDate"/>
                </v-col>
              </v-row>
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
          :disabled="isLoading || profile.nickname.length < 3"
          @click="sendPayload()"
      >
        {{ $i18n.t('welcome.create_profile') }}
      </v-btn>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'
import validators from "../../utils/validators"
import { DirectUpload } from '@rails/activestorage'
import DatePicker from "../Elements/Forms/DatePicker";

export default {
  components: {
    DatePicker,
    DialogContent
  },
  data: () => ({
    isLoading: false,
    isValid: false,
    image: null,
    url: null,
    profile: {
      nickname: '',
      description: '',
      profileAttrs: {
        placeBirth: '',
        birthDate: '',
      },
      avatar: '',
    },
    rules: {
      required: value => validators.required(value),
    }
  }),
  computed: {
    ...mapState({
      community: state => state.community,
    }),
    inputLabel() {
      return (this.image)
          ? this.$i18n.t('communities.member.edit.change_avatar')
          : this.$i18n.t('communities.member.edit.select_avatar')
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
      addOfflineMember: 'families/addOfflineMember',
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
          this.profile.avatar = null
        } else {
          this.profile.avatar = blob.signed_id
        }
        this.isLoading = false
      })
    },
    sendPayload() {
      this.isLoading = true
      if (!this.profile.avatar) delete this.profile.avatar
      this.addOfflineMember(this.profile)
          .then(() => {
            this.closeDialog()
          })
          .catch((error) => {
            this.setError(error)
          })
          .finally(() => {
            this.isLoading = false
          })
    },
  }
}
</script>
<style lang="scss" scoped>
.profile-setup {
  &__description {
    font-family: Lato;
    font-size: 16px;
    line-height: 24px;
    color: $color-tertiary;
  }
  &__heading {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 20px;
    line-height: 24px;
    color: $color-tertiary;
  }
}
.required-disclaimer {
  font-weight: bold;
  font-size: 12px;
  line-height: 14px;

  color: $color-required;
}
.avatar-edit {
  position: relative;
  box-sizing: border-box;
  max-width: 208px;
  border-radius: 156px;
  width: 100%;
  cursor: pointer;
  background: $color-dark-white;
  border: 2px dashed $color-disabled;
  max-height: 208px;
  &:hover {
    background: $color-light-grey;
  }
  &__image {
    position: relative;
    min-height: 208px;
    min-width: 208px;
    display: flex;
    justify-content: center;
    align-content: center;
  }
  &__label {
    position: absolute;
    bottom: 30px;
    width: 100%;
    background: $primary-white;
    border-radius: 0 0 3px 3px;
    opacity: 0.8;
    display: flex;
    align-items: center;
    justify-content: center;
    height: 42px;
    font-weight: bold;
    font-size: 16px;
    line-height: 120%;
    text-align: center;
    color: $color-tertiary;
  }
  &__icon {
    font-size: 100px !important;
  }
  .hidden-input-file {
    position: absolute;
    z-index: -1;
    .v-icon {
      display: none;
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
::v-deep .v-text-field--outlined .v-input__prepend-outer, .v-text-field--outlined .v-input__append-outer {
  margin-top: 5px;
}
</style>
