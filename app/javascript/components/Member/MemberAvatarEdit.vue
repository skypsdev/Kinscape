<template>
  <label class="avatar-edit" @click="openFileUpload">
    <div class="avatar-edit__image">
      <v-icon v-if="!avatarUrl" class="avatar-edit__icon" color="#C4C4C4">
        mdi-image-outline
      </v-icon>
      <v-avatar size="208" v-else>
        <v-img :src="avatarUrl" height="208px">
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
    </div>

    <div class="avatar-edit__label">
      <template v-if="!member.isLoading">
        {{ inputLabel }}
      </template>
      <v-progress-circular v-else indeterminate color="#C4C4C4" />
    </div>
  </label>
</template>

<script>
import { mapActions, mapState } from 'vuex'

export default {
  computed: {
    ...mapState({
      member: (store) => store.members.member
    }),
    avatarUrl() {
      return this.member.avatarUrl
    },
    inputLabel() {
      return this.avatarUrl
        ? this.$i18n.t('communities.member.edit.change_avatar')
        : this.$i18n.t('communities.member.edit.select_avatar')
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      updateAvatar: 'members/updateAvatar'
    }),
    async handleImageChange([image]) {
      try {
        await this.updateAvatar(image.signedId)
      } catch (err) {
        console.error(err)
      }
    },
    openFileUpload() {
      this.setDialog({
        component: 'UploadDialog',
        customClass: 'upload-dialog',
        customSize: '800px',
        data: { callback: this.handleImageChange },
      })
    }
  }
}
</script>

<style lang="scss">
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
</style>
