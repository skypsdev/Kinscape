<template>
  <DialogContent>
    <template v-slot:content>
      <v-form
        ref="profileForm"
        @submit.prevent="createProfile"
      >
        <v-row class="mt-12">
          <v-col cols="12" md="4" class="d-flex justify-center justify-md-end">
            <label class="avatar-edit mt-1 mr-md-4 mb-auto">
              <div class="avatar-edit__image">
                <Avatar
                  :src="url"
                  size="biggest"
                />
                <v-file-input
                  ref="inputAvatar"
                  id="avatar"
                  class="hidden-input-file"
                  accept="image/*"
                  hide-input
                  v-model="image"
                  @change="handleImageChange"
                />
              </div>

              <div class="avatar-edit__label">
                <template>
                  {{ inputLabel }}
                </template>
              </div>
            </label>
          </v-col>
          <v-col>
            <div
              v-if="currentUser.registrationMethod === 'member'"
              class="setup-profile-dialog__description mb-10"
            >
              {{ $i18n.t('account.submit_profile.description_member') }}
            </div>
            <div
              v-else-if="currentUser.registrationMethod === 'follower'"
              class="setup-profile-dialog__description mb-10"
            >
              {{ $i18n.t('account.submit_profile.description_follower') }}
            </div>

            <h4 class="profile-setup__heading f--tertiary d-inline-block mr-3">{{ $i18n.t('welcome.name_label') }}</h4>
            <p class="required-disclaimer d-inline-block mb-3">{{ $i18n.t('communities.newCommunityDialog.required') }}</p>
            <v-row>
              <v-col cols="12" md="11">
                <v-text-field
                  :placeholder="$i18n.t('welcome.name_placeholder')"
                  v-model="profile.name"
                  :rules="[rules.required]"
                  outlined
                  single-line
                  color="primary"
                  type="text"
                  height="48"
                />
              </v-col>
            </v-row>

            <h4 class="profile-setup__heading f--tertiary d-inline-block mr-3 mb-3">
              {{ $i18n.t('welcome.info_label') }}
            </h4>
            <v-row>
              <v-col cols="12" md="5">
                <SetupProfileFormField
                  v-model="defaults.email"
                  icon="mdi-email-outline"
                  label="Email"
                  :options="formDefaults.emails.options"
                >
                  <v-text-field
                    :placeholder="$i18n.t('account.submit_profile.placeholder_email')"
                    v-model="profile.email"
                    outlined
                    single-line
                    color="primary"
                    type="text"
                    dense
                  />
                </SetupProfileFormField>
              </v-col>
              <v-col cols="12" md="5" offset-md="1">
                <SetupProfileFormField
                  icon="mdi-target"
                  label="Location"
                >
                  <v-text-field
                    :placeholder="$i18n.t('account.submit_profile.placeholder_location')"
                    v-model="profile.location"
                    outlined
                    single-line
                    color="primary"
                    type="text"
                    dense
                  />
                </SetupProfileFormField>
              </v-col>
              <v-col cols="12" md="5">
                <SetupProfileFormField
                  icon="mdi-calendar-outline"
                  label="Birth Date"
                >
                  <DatePicker
                    v-model="profile.birthdate"
                    background-color="white"
                    :showCalendarIcon="false"
                  />
                </SetupProfileFormField>
              </v-col>
              <v-col cols="12" md="5" offset-md="1">
                <SetupProfileFormField
                  v-model="defaults.phone"
                  icon="mdi-phone-outline"
                  label="Phone Number"
                  :options="formDefaults.phone_numbers.options"
                >
                  <v-text-field
                    :placeholder="$i18n.t('account.submit_profile.placeholder_phone')"
                    v-model="profile.phone"
                    outlined
                    single-line
                    color="primary"
                    type="text"
                    dense
                  />
                </SetupProfileFormField>
              </v-col>
            </v-row>

            <v-checkbox
              v-if="toPrivateProfile"
              v-model="profile.private"
              :label="$i18n.t('account.submit_profile.apply_to_private')"
            />
          </v-col>
        </v-row>

        <div class="d-flex justify-center my-10">
          <v-btn
            class="elevation-0"
            color="primary"
            rounded
            type="submit"
            :disabled="!kinshipLoaded"
          >
            {{ $i18n.t('welcome.create_profile') }}
          </v-btn>
        </div>
      </v-form>
    </template>
  </DialogContent>
</template>

<script>
import { mapState, mapActions } from 'vuex'
import { DirectUpload } from '@rails/activestorage'

import kinshipsRepository from '@/repositories/kinships-repository'
import usersRepository from '@/repositories/users-repository'
import validators from "@/utils/validators"

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import SetupProfileFormField from '@/components/Profiles/SetupProfileFormField.vue'
import formDefaults from '@/components/Profiles/ProfileContactDetailsDefaults'
import DatePicker from '@/components/Elements/Forms/DatePicker'
import Avatar from '@/components/Elements/Avatar.vue'

import EventBus from '@/plugins/event-bus'

export default {
  components: {
    DialogContent,
    SetupProfileFormField,
    DatePicker,
    Avatar
  },
  data: () => ({
    url: '',
    image: null,
    profile: {
      name: '',
      email: '',
      location: '',
      birthdate: '',
      phone: '',
      private: false
    },
    defaults: {
      email: formDefaults.emails.options[0].value,
      phone: formDefaults.phone_numbers.options[0].value
    },
    rules: {
      required: value => validators.required(value),
    },
    formDefaults,
    kinshipId: null,
    privateKinshipId: null
  }),
  computed: {
    ...mapState({
      families: state => state.families.simpleList.families,
      currentUser: state => state.core.user
    }),
    inputLabel() {
      return (this.image)
        ? this.$i18n.t('communities.member.edit.change_avatar')
        : this.$i18n.t('communities.member.edit.select_avatar')
    },
    toPrivateProfile () {
      return this.currentUser.registrationMethod === 'member' ||
        this.currentUser.registrationMethod === 'follower'
    },
    kinshipLoaded () {
      if (this.toPrivateProfile) {
        return this.kinshipId && this.privateKinshipId
      }

      return this.kinshipId
    }
  },
  mounted () {
    this.loadKinships()
    this.profile.name = this.currentUser.name
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      showTooltips: 'core/showTooltips'
    }),
    handleImageChange () {
      this.url = URL.createObjectURL(this.image)
    },
    async createProfile () {
      let payload = {
        nickname: this.profile.name,
        profile_attrs: {}
      }

      if (!this.$refs.profileForm.validate()) {
        return
      }

      const dob = new Date(this.profile.birthdate)

      if (this.url) {
        payload.avatar = await this.addAvatar(this.image)
      }
      if (this.profile.email) {
        payload.profile_attrs.emails = [{
          id: 0,
          title: this.defaults.email,
          type: 'text',
          value: [{
            name: 'email',
            value: this.profile.email
          }]
        }]
      }
      if (this.profile.location) {
        payload.profile_attrs.locations = [{
          id: 0,
          title: 'Current',
          type: 'text',
          value: [{
            name: 'location',
            value: this.profile.location
          }]
        }]
      }
      if (!isNaN(dob.getTime())) {
        payload.profile_attrs.birth_date = [{
          id: 0,
          title: 'Birth Date',
          type: 'date',
          value: [{
            name: 'birth_date',
            value: this.profile.birthdate
          }]
        }]
      }
      if (this.profile.phone) {
        payload.profile_attrs.phone_numbers = [{
          id: 0,
          type: 'text',
          title: 'text',
          value: [{
            name: 'phoneNumber',
            value: this.profile.phone
          }]
        }]
      }

      if (
        this.currentUser.registrationMethod === 'member' ||
        this.currentUser.registrationMethod === 'follower'
      ) {
        await kinshipsRepository.updateKinship(this.kinshipId, payload)

        if (this.toPrivateProfile && this.profile.private) {
          await kinshipsRepository.updateKinship(this.privateKinshipId, payload)
        }
      } else {
        await kinshipsRepository.updateKinship(this.privateKinshipId, payload)
      }

      this.currentUser.onboarding.pending = false
      usersRepository.updateUser({
        onboarding: this.currentUser.onboarding
      })
      this.closeDialog()
      this.showTooltips()

      EventBus.$emit('updated:profile')
    },
    addAvatar (image) {
      return new Promise((resolve, reject) => {
        const upload = new DirectUpload(image, '/rails/active_storage/direct_uploads')
        upload.create((error, blob) => {
          if (error) {
            this.setError(`Direct upload failed: ${error}`)
            this.image = null
            this.url = null
            reject(error)
          } else {
            resolve(blob.signed_id)
          }
        })
      })
    },
    loadKinships () {
      if (this.currentUser.registrationMethod === 'member') {
        const familyId = this.families?.[0]?.id
        if (familyId) {
          kinshipsRepository.getKinshipByFamily(familyId)
            .then(({ data }) => { this.kinshipId = data.id })
        }
      } else {
        kinshipsRepository.getKinshipByFamily(this.currentUser.familyId)
          .then(({ data }) => { this.kinshipId = data.id })
      }

      kinshipsRepository.getKinshipByFamily(this.currentUser.privateFamilyId)
        .then(({ data }) => { this.privateKinshipId = data.id })
    }
  }
}
</script>

<style lang="scss">
.setup-profile {
  &__heading {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 20px;
    line-height: 24px;
    color: $color-tertiary;
  }
}

.avatar-edit {
  position: relative;
  box-sizing: border-box;
  max-width: 208px;
  border-radius: 156px;
  width: 100%;
  cursor: pointer;
  background: $color-medium-grey;

  &:hover {
    background: $medium-grey;
  }
  &__image {
    position: relative;
    min-height: 208px;
    display: flex;
    justify-content: center;
    align-content: center;
  }
  &__label {
    position: absolute;
    bottom: 30px;
    width: 100%;
    background: #ffffff;
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

.required-disclaimer {
  font-weight: bold;
  font-size: 12px;
  line-height: 14px;

  color: $color-required;
}
</style>
