<template>
  <!-- TODO: vue/no-mutating-props -->
  <!-- eslint-disable vue/no-mutating-props --->
  <section
    class="profile-details main-section"
  >
    <div
      class="cover-image-wrapper img-rotate"
      tooltip-placement="right"
    >
      <div
        class="style-wrapper user-avatar-box"
      >
        <div
          class="image-div w200"
        >
          <fa-icon
            v-if="isLoading"
            class="image-loader"
            icon="circle-notch"
            size="2x"
            spin
          />
          <div
            :class="[
              'dropbox cover-image',
              isLoading ? 'opacity-img' : ''
            ]"
            :style="{ backgroundImage: 'url(' + newAvatarUrl + ')' }"
          >
            <input
              type="file"
              accept="image/*"
              class="input-file"
              @change="filesChange"
            >
          </div>
        </div>
        <filestack
          ref="fpick"
          :class="{'disable-btn':
            !kinship.attributes.is_current_user_connector &&
            kinship.attributes.user_id !== currentUser.id}"
          :max-files="1"
          :options="{
            accept: 'image/*',
            onOpen: () => setSecurityPolicy(this.$refs.fpick),
            onUploadDone: (res) => uploadDone(res)
          }"
        >
          <div
            v-if="canManage"
            class="filepicker-wrapper w200"
          >
            <button
              class="filepicker"
              type="button"
              :class="{'disable-btn':
                !kinship.attributes.is_current_user_connector &&
                kinship.attributes.user_id !== currentUser.id}"
            >
              Change avatar
            </button>
          </div>
        </filestack>
      </div>
    </div>

    <div class="ml44">
      <div id="user_name" class="name">
        <h6 class="profile-desc-title">
          {{
            (editingUser &&
              editingUser.attributes &&
              editingUser.attributes.name) ||
              kinship.attributes.nickname
          }}
        </h6>
        <div
          v-if="editingUser"
          id="user_email"
          class="email"
        >
          {{ editingUser.attributes.email }}
        </div>
      </div>
      <div
        v-if="false"
        class="action-button menu-item w-auto"
      >
        <!-- v-if="!isCurrentUser && editingUser"
          TODO: currently send message button does nothing -->
        <menu-item
          :user="{ id: editingUser.id, ...editingUser.attributes }"
          :current-user="currentUser"
          portal-id="#vue-modal-profile"
          modal-name="message-modal-profile"
        >
          {{ $i18n.t('shared.users.send_message') }}
        </menu-item>
      </div>
      <ul
        class="user-details custom-user-details gap-16"
      >
        <!--        <li-->
        <!--          v-if="editMode"-->
        <!--          class="detail"-->
        <!--        >-->
        <!--          <i class="fa"><fa-icon icon="signature" /></i>-->
        <!--          <input-->
        <!--            v-model="editingUser.attributes.first_name"-->
        <!--            :class="{'disable-btn':-->
        <!--              !kinship.attributes.is_current_user_connector &&-->
        <!--              kinship.attributes.user_id != currentUser.id}"-->
        <!--            class="for-li-items"-->
        <!--            placeholder="First Name"-->
        <!--            @input="saveOfflineMember"-->
        <!--          >-->
        <!--        </li>-->
        <!--        <li-->
        <!--          v-if="editMode"-->
        <!--          class="detail"-->
        <!--        >-->
        <!--          <i class="fa"><fa-icon icon="signature" /></i>-->
        <!--          <input-->
        <!--            v-model="editingUser.attributes.last_name"-->
        <!--            :class="{'disable-btn':-->
        <!--              !kinship.attributes.is_current_user_connector &&-->
        <!--              kinship.attributes.user_id != currentUser.id}"-->
        <!--            class="for-li-items"-->
        <!--            placeholder="Last Name"-->
        <!--            @input="saveOfflineMember"-->
        <!--          >-->
        <!--        </li>-->
        <li
          v-if="(kinship.attributes.nickname && editingUser) || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="tags" /></i>
          <span v-if="!editMode">{{ kinship.attributes.nickname }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.nickname"
            class="for-li-items"
            :class="{'disable-btn':
              !kinship.attributes.is_current_user_connector &&
              kinship.attributes.user_id !== currentUser.id}"
            placeholder="Nickname"
            @input="saveKinship"
          >
        </li>
        <li
          v-if="kinship.attributes.email || editMode"
          id="kinship_email"
          class="detail"
        >
          <i class="fa"><fa-icon :icon="['far', 'envelope']" /></i>
          <span v-if="!editMode">{{ kinship.attributes.email }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.email"
            class="for-li-items"
            placeholder="Email"
            :disabled="!kinship.attributes.user_id"
            @blur="saveKinshipEmail"
          >
        </li>
        <li
          v-if="kinship.attributes.phone || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="phone" /></i>
          <span v-if="!editMode">{{ kinship.attributes.phone }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.phone"
            class="for-li-items"
            placeholder="Phone"
            :class="{'disable-btn':
              !kinship.attributes.is_current_user_connector &&
              kinship.attributes.user_id !== currentUser.id}"
            @input="saveKinship"
          >
        </li>
        <li
          v-if="kinship.attributes.birth_place || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="map" /></i>
          <span v-if="!editMode">{{ kinship.attributes.birth_place }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.birth_place"
            class="for-li-items"
            placeholder="Birth Place"
            :class="{'disable-btn':
              !kinship.attributes.is_current_user_connector &&
              kinship.attributes.user_id !== currentUser.id}"
            @input="saveKinship"
          >
        </li>
        <li
          v-if="kinship.attributes.address || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="map-pin" /></i>
          <span v-if="!editMode">{{ kinship.attributes.address }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.address"
            class="for-li-items"
            placeholder="Address"
            :class="{'disable-btn':
              !kinship.attributes.is_current_user_connector &&
              kinship.attributes.user_id !== currentUser.id}"
            @input="saveKinship"
          >
        </li>
        <!-- <li
          v-if="kinship.attributes.location || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="map-marker" /></i>
          <span v-if="!editMode">{{ kinship.attributes.location }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.location"
            class="for-li-items"
            placeholder="Location"
            @input="saveKinship"
          >
        </li> -->
        <!-- <li
          v-if="kinship.attributes.birth_date || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon :icon="['far', 'calendar-alt']" /></i>
          <span v-if="!editMode">
            {{
              $i18n.t('shared.users.birth_date',
                      { birth_date: kinship.attributes.birth_date })
            }}
          </span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.birth_date"
            class="for-li-items"
            :class="{'disable-btn':
              !kinship.attributes.is_current_user_connector &&
              kinship.attributes.user_id != currentUser.id}"
            placeholder="Birth Date"
            type="date"
            @input="saveKinship"
          >
        </li> -->
        <li
          v-if="kinship.attributes.birth_date || editMode"
          class="w-100"
        >
          <div
            class="dates"
            :title="$i18n.t('stories.meta.date_title')"
          >
            <div class="datesHolder">
              <div class="fromDate date-div-design">
                <div>
                  <span
                    class="story-label"
                  >
                    <i class="fa pr10">
                      <fa-icon :icon="['far', 'calendar-alt']" />
                    </i>
                    Birth date
                  </span>
                </div>
                <DatePicker v-model="kinship.attributes.birth_date" @input="saveKinship"/>
              </div>
              <div
                v-if="isRange && (kinship.attributes.death_date || editMode)"
                class="toDate date-div-design"
              >
                <i class="fa pr10"><fa-icon icon="ribbon" /></i>
                <span class="story-label">
                  Death date
                </span>
                <DatePicker v-model="kinship.attributes.death_date" @input="saveKinship"/>
              </div>
              <div class="isRange">
                <input
                  v-model="isRange"
                  type="checkbox"
                  class="story-isRange"
                >
                <span>this profile spans a range of dates</span>
              </div>
            </div>
          </div>
        </li>
        <!-- <li
          v-if="kinship.attributes.death_date || editMode"
          class="detail"
        >
          <i class="fa"><fa-icon icon="ribbon" /></i>
          <span v-if="!editMode">{{ kinship.attributes.death_date }}</span>
          <input
            v-if="editMode"
            v-model="kinship.attributes.death_date"
            class="for-li-items"
            placeholder="Death Date"
            @input="saveKinship"
          >
        </li> -->
      </ul>
    </div>
  </section>
  <!-- eslint-enable -->
</template>

<script>
import {mapActions, mapState} from 'vuex'
import { DirectUpload } from '@rails/activestorage'
import { KinshipsRepository } from '../../repositories'
import Filestack from '../shared/filestack'
import MenuItem from '../header/menu/item'
import DatePicker from "../Elements/Forms/DatePicker";

export default {
  components: {DatePicker, MenuItem, Filestack },
  props: {
    user: {
      type: Object,
      required: true
    },
    kinship: {
      type: Object,
      required: true
    },
    editMode: Boolean
  },
  data () {
    return {
      editingUser: this.user,
      newAvatarUrl: this.kinship.attributes.avatar_url,
      coverUrl: '',
      policy: '',
      signature: '',
      isLoading: false,
      isRange: false,
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    isCurrentUser () {
      return this.currentUser.id === (this.editingUser && this.editingUser.id)
    },
    canManage () {
      return this.isCurrentUser
    },
  },
  methods: {
    ...mapActions({
      failureFlashMessage: 'failureFlashMessage'
    }),
    async filesChange (e) {
      if (this.canManage) {
        if (!this.kinship.attributes.is_current_user_connector &&
          this.kinship.attributes.user_id !== parseInt(this.currentUser.id)) {
          this.failureFlashMessage('Only administrator can change avatar.')
        } else {
          var files = e.target.files
          if (!files[0].type.match('image/*')) {
            this.failureFlashMessage(
              'accepted file type are image/*'
            )
            return
          }
          this.isLoading = true
          var reader = new FileReader()
          reader.onload = e => {
            this.newAvatarUrl = e.target.result
          }
          reader.readAsDataURL(files[0])

          var file = files[0]
          let directUploadPath = '/rails/active_storage/direct_uploads'
          if (file) {
            const upload = await new DirectUpload(file, directUploadPath)
            upload.create((error, blob) => {
              if (error) {
                throw new Error(`Direct upload failed: ${error}`)
              } else {
                this.dragDrop(e.target.files, blob.signed_id)
              }
            })
          }
        }
      } else {
        this.failureFlashMessage('Unauthorized')
      }
    },
    async dragDrop (event, url) {
      const file = event[0]

      let avatarImage = {}
      avatarImage.filename = file.name
      avatarImage.size = file.size
      avatarImage.url = url
      if (this.kinship.attributes.media_avatar) {
        avatarImage.id = this.kinship.attributes.media_avatar.id
      }
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.kinship.attributes.media_avatar_attributes = avatarImage
      await this.saveKinship()
    },
    setSecurityPolicy (filepicker) {
      try {
        KinshipsRepository.getConfig(this.kinship.id)
          .then(response => {
            filepicker.setSecurity(response)
            this.policy = response.policy
            this.signature = response.signature
          })
      } catch (error) {
        console.error(error)
      }
    },
    uploadDone (event) {
      if (event.filesUploaded.length === 0) return
      const file = event.filesUploaded[0]

      let avatarImage = {}
      avatarImage.mimetype = file.mimetype
      avatarImage.filename = file.filename
      avatarImage.size = file.size
      avatarImage.url = file.url
      if (this.kinship.attributes.media_avatar) {
        avatarImage.id = this.kinship.attributes.media_avatar.id
      }
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.kinship.attributes.media_avatar_attributes = avatarImage
      this.saveKinship()
      this.newAvatarUrl =
        `${file.url}?policy=${this.policy}&signature=${this.signature}`
    },
    openFileUpload () {
      const fileInput = document.createElement('input')
      fileInput.setAttribute('type', 'file')
      const that = this
      fileInput.addEventListener('change', function () {
        const file = Array.from(fileInput.files)[0]
        that.saveAvatar(file)
      })
      fileInput.click()
    },
    saveAvatar (file) {
      if (file.type.indexOf('image/') === 0) {
        let url = this.$blobPath
        if (file) {
          this.$emit('update:savingStatus', 'started')
          const upload = new DirectUpload(file, this.$directUploadPath)
          upload.create((error, blob) => {
            if (error) {
              this.$emit('update:savingStatus', 'failed')
              throw new Error(`Direct upload failed: ${error}`)
            } else {
              url = url.replace('signed_id', blob.signed_id)
              url = url.replace('filename', blob.filename)
              this.newAvatarUrl = encodeURI(url)
              // TODO Fix mutating prop
              // eslint-disable-next-line vue/no-mutating-props
              this.kinship.attributes.avatar = blob.signed_id
              this.saveKinship()
              this.$emit('update:savingStatus', 'finished')
            }
          })
        }
      } else {
        alert('File not allowed. Only Image files can be uploaded.')
      }
    },
    saveKinship () {
      const { ...data } = this.kinship.attributes
      if (this.timeout) clearTimeout(this.timeout)
      this.timeout = setTimeout(async () => {
        try {
          await KinshipsRepository.updateKinship(
            this.kinship.id,
            data
          )
          this.isLoading = false
          this.$emit('success')
          this.$emit('update:savingStatus', 'finished')
        } catch (error) {
          console.error(error)
          this.$emit('failure')
          this.$emit('update:savingStatus', 'failed')
        }
      }, 500)
    },
    saveKinshipEmail () {
      if (this.timeout) clearTimeout(this.timeout)
      let payload = {
        'email': this.kinship.attributes.email
      }
      this.timeout = setTimeout(async () => {
        try {
          await KinshipsRepository.updateKinship(this.kinship.id, payload)
            .then(response => {
              if (response.message) {
                this.failureFlashMessage(response.message)
              }
              this.isLoading = false
              this.$emit('success')
              this.$emit('update:savingStatus', 'finished')
            })
        } catch (error) {
          console.error(error)
          this.$emit('failure')
          this.$emit('update:savingStatus', 'failed')
        }
      }, 500)
    },
    saveOfflineMember () {
      if (this.timeout) clearTimeout(this.timeout)
      this.timeout = setTimeout(() => {
        this.$emit('update:savingStatus', 'started')
        // TODO-OFFLINE-MEMBER
        this.$http.put(
          `/api/v1/families/${this.kinship.attributes.family_id}/wards/${this.editingUser.id}`,
            this.editingUser.attributes
        ).then(response => {
          this.editingUser.attributes = response.body
          this.$emit('success')
          this.$emit('update:savingStatus', 'finished')
        }, () => {
          this.$emit('failure')
          this.$emit('update:savingStatus', 'failed')
        })
      }, 100)
    }
  }
}
</script>

<style lang="scss" scoped>
  .toDate {
    margin-top: 10px;
  }
  .disable-btn {
    cursor: not-allowed;
    pointer-events: none;
    opacity: 0.4;
  }

  .uppload-avatar-wrapper {
    margin-top: 25px;
  }
  .detail input {
    width: calc(100% - 32px - 0.6em);
    padding: 4px;
  }

  #user_email {
    color: rgb(140, 152, 168);
    text-align: left;
  }

  #kinship_email {
    color: rgb(140, 152, 168);
    text-align: left;
  }

   .dropbox, .image_style {
    outline: 2px dashed grey; /* the dash box */
    outline-offset: -10px;
    background: lightcyan;
    color: dimgray;
    min-height: 200px; /* minimum height */
    position: relative;
    cursor: pointer;
    background-size: contain !important;
    background-position: center center !important;
    background-repeat: no-repeat !important;
  }

  .input-file {
    opacity: 0; /* invisible but it's there! */
    width: 100%;
    height: 200px;
    position: absolute;
    cursor: pointer;
  }

  .dropbox:hover {
    background: lightblue; /* when mouse over to the drop zone, change color */
  }

  .dropbox p {
    font-size: 1.2em;
    text-align: center;
    padding: 50px 0;
  }
  .image-loader {
    color: #f75209;
    transition: .5s ease;
    z-index: 2;
    opacity: 1;
    position: absolute;
    top: 42%;
    left: 48%;
    transform: translate(-50%, -50%);
    -ms-transform: translate(-50%, -50%);
    text-align: center;
    margin-left: -6px !important;
    margin-top: -20px !important;
  }
  .opacity-img {
    opacity: 0.3;
  }

  .name{
    margin-bottom: 30px;
  }
  .profile-desc-title {
    text-align: left;
    font-size: 48px;
  }
  .main-section{
    display: flex !important;
    margin: 24px 0 !important;
    justify-content: center;
  }
  .user-avatar-box{
    margin-top:20px !important;
    box-shadow: 0 0 0 1px rgba(0, 0, 0, 0.15), 0 1px 10px 0 rgba(0, 0, 0, 0.1);
    background: #fff !important;
    padding: 8px !important;
  }
  .w200{
    width: 200px !important;
  }
  .img-rotate{
    transform: rotate(-7deg) !important;
  }
  .ml44{
    margin-left:44px !important;
  }
  .custom-user-details{
    width: 100% !important;
    display: flex !important;
    flex-wrap: wrap !important;
  }
  .for-li-items{
    border: none;
    box-shadow: none;
    display: inline-block;
    margin-left: 10px;
  }
  .w-auto{
    width: fit-content;
  }
  .gap-16{
    gap: 16px;
  }
  .mx2 {
    margin-left: 8px;
    margin-right: 8px;
  }
  .year {
    max-width: 70px;
    text-align: center;
    padding: 1px;
    margin-bottom: 0 !important;
  }
  .month {
        width: 100%;
    max-width: 155px;
  }
  .date {
    width: 100%;
    max-width: 90px;
  }
  .pr10{
    padding-right: 10px;
  }
  .w-100 {
    width:100%
  }
  .date-div-design {
    display: flex;
    align-items: stretch;
  }
</style>
