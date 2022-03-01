<template>
  <div class="community-avatar">
    <div class="community-avatar__image">
      <div
          v-if="!isCustomAvatar"
          class="community-avatar__icon"
      >
        <v-img :src="require('../../assets/images/community-blank.png')" contain height="208px"/>
      </div>
      <v-img
          v-else
          :src="cover"
          height="208px"
      >
        <template v-slot:placeholder>
          <v-progress-circular
              class="community-avatar__loader"
              indeterminate
              color="medium_grey"
          />
        </template>
      </v-img>
    </div>
  </div>
</template>

<script>
import {mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      cover: state => state.families.community.content.cover
    }),
    isCustomAvatar() {
      return this.cover
    }
  }
}
</script>

<style lang="scss">
.community-avatar {
  background: $color-dark-white;
  border-radius: 5px;
  overflow: hidden;
  max-width: 208px;
  min-height: 208px;
  width: 100%;
  &__image {
    position: relative;
    height: 208px;
    display: flex;
    justify-content: center;
    align-content: center;
  }
  &__loader {
    margin: auto;
    height: 100% !important;
    display: flex;
  }
  &__icon {
    margin: auto;
    display: flex;
  }
}
</style>
