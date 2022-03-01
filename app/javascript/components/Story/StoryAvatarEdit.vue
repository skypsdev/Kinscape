<template>
  <label class="story-avatar-edit">
    <div class="story-avatar-edit__image">
      <v-icon
        v-if="!isCustomAvatar"
        class="story-avatar-edit__icon"
        color="medium_grey"
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
              color="medium_grey"
            />
          </div>
        </template>
      </v-img>
      <v-file-input
        ref="inputStoryAvatar"
        id="story-avatar"
        class="hidden-input-file"
        accept="image/*"
        hide-input
        v-model="image"
        :disabled="story.isLoading"
        @change="handleImageChange"
      />
    </div>
    
    <div class="story-avatar-edit__label">
      <template v-if="!story.isLoading">
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

<script>
import {mapActions, mapState} from 'vuex'

export default {
  data () {
    return {
      image: null,
      url: null,
    }
  },
  computed: {
    ...mapState({
      story: store => store.stories.story
    }),
    isCustomAvatar() {
      return this.image || (this.url && this.url.includes('/active_storage/'))
    },
    inputLabel() {
      return (this.isCustomAvatar)
        ? this.$i18n.t('stories.change_cover')
        : this.$i18n.t('stories.select_cover')
    }
  },
  watch: {
    'story.content.cover' () {
      this.url = this.story.content.cover
    }
  },
  mounted () {
    this.url = this.story.content.cover
  },
  methods: {
    ...mapActions({
      updateStoryAvatar: 'stories/updateStoryAvatar',
    }),
    handleImageChange() {
      this.url= URL.createObjectURL(this.image)
      if (this.image) this.updateStoryAvatar(this.image)
    }
  }
}
</script>

<style lang="scss">
.story-avatar-edit {
  background: $color-dark-white;
  border: 2px dotted #D0D0D0;
  box-sizing: border-box;
  border-radius: 5px;
  max-width: 208px;
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
</style>
