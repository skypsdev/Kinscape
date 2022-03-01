<template>
  <v-hover v-slot="{ hover }">
    <v-card
        elevation="0"
        :class="{ 'community-card--active': hover }"
        class="community-card mx-auto d-flex flex-column"
        :to="{
          name: 'showFamily',
          params: { id: community.id }
        }"
    >
      <v-img
          :src="community.attributes.cover_url || require('../../assets/images/community-blank.png')"
          height="203px"
          class="community-card__image"
      >
        <div
            v-if="community.attributes.is_connected_by_current_user"
            class="community-card__label"
        >
          Admin
        </div>

        <div class="community-card__chips">
          <v-chip
              class="community-card__chip"
              text-color="text"
          >
            {{ community.attributes.family_type.toUpperCase() }}
          </v-chip>
        </div>

      </v-img>
      <v-row>
        <v-col cols="3" class="d-flex justify-center align-center pr-0">
          <Avatar
              :src="community.attributes.admin_avatar_url"
          />
        </v-col>
        <v-col cols="9" class="pl-0">
          <div class="community-card__title pt-1">
            <span>{{ community.attributes.name }}</span>
          </div>
          <div class="community-card__sub-title">
            <span>
              Admin · {{ community.attributes.is_connected_by_current_user ? 'You' : community.attributes.connector_name }}
            </span>
          </div>
        </v-col>
      </v-row>
    </v-card >
  </v-hover>
</template>

<script>
import { mapState } from 'vuex'
import Avatar from "../Elements/Avatar";
export default {
  components: {Avatar},
  props: {
    community: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
  },
}
</script>

<style lang="scss" scoped>
.community-card {
  border: 2px solid $color-light-grey;
  border-radius: 10px !important;
  min-height: 264px;
  height: 264px;
  min-width: 264px;
  width: 264px;
  overflow: hidden;
  &--active {
    border-color: $color-primary;
    background-color: rgba(252, 208, 196, 0.2);
  }
  &__image {
    position: relative;
    background-color: #F1F1F1;
    border-radius: 0 !important;
  }
  &__avatar {
    margin-right: 13px;
  }
  &__title {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-tertiary;
    display: flex;
    span {
      flex: 1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }
  &__sub-title {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 14px;
    line-height: 19px;
    color: $color-grey;
    display: flex;
    span {
      flex: 1;
      white-space: nowrap;
      overflow: hidden;
      text-overflow: ellipsis;
    }
  }
  &__label {
    position: absolute;
    left: 0;
    top: 21px;
    z-index: 10;
    padding: 4px 12px;
    background: #8B78FE;
    border-radius: 2px 10.5px 10.5px 2px;
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 16px;
    line-height: 21px;
    color: #FFFFFF;
  }
  &__chips {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    z-index: 10;
    padding: 8px;
    display: flex;
    flex-direction: row;
    justify-content: space-between;
    align-items: flex-end;
  }
  &__chip {
    height: 24px;
    margin: 4px;
    background: $color-light-grey !important;
    opacity: 1;
    font-family: Lato;
    font-weight: bold;
    font-size: 14px;
    line-height: 180%;
  }
}
</style>
