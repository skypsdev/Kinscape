<template>
  <div>
    <v-menu
        bottom
        offset-y
        nudge-left="175"
        v-model="displaySwitcher"
        content-class="shared-in-menu"
        :close-on-content-click="false"
        :disabled="!isShared"
    >
      <template v-slot:activator="{ attrs }">
        <v-btn
            class="mx-1"
            rounded
            outlined
            color="primary"
            elevation="0"
            :title="$i18n.t('stories.action_button.share_title')"
            v-bind="attrs"
            @click="toggleMenu"
        >
          <v-icon left>mdi-redo</v-icon>
          {{ $i18n.t(`stories.action_button.${isShared? 'shared_in' : 'share'}`) }}
        </v-btn>
      </template>
      <div class="shared-in-menu__wrapper">
        <v-row no-gutters>
          <v-col class="shared-in-menu__sidebar">
            <v-list dense class="shared-in-menu__list">
              <v-list-item class="shared-in-menu__title mb-4">
                {{ $i18n.t('stories.shared_in.title') }}
              </v-list-item>
              <v-list-item class="mb-4">
                <Search
                    :searchTerm="search"
                    @setSearch="handleSearch"
                    class="shared-in-menu__search"
                />
              </v-list-item>
              <div
                  v-for="publication in publicationsWithFamily"
                  :key="publication.id"
              >
                <v-list-item
                    class="shared-in-menu__link d-flex flex-row px-3"
                    @click="unShareItem(publication.id)"
                >
                  <Avatar
                      :src="publication.community.attributes.coverUrl"
                      size="small"
                  />
                  <span class="pl-3">
                    {{ publication.community.attributes.name }}
                  </span>
                  <v-img
                      class="ml-auto mr-0"
                      max-width="15"
                      contain
                      :src="require('../../../assets/images/unshare_icon.svg')"
                  />
                  <span class="shared-in-menu__unshare ml-2 mr-1">
                    {{ $i18n.t('stories.shared_in.unshare') }}
                  </span>
                </v-list-item>
                <v-divider/>
              </div>
            </v-list>
            <div class="d-flex flex-column justify-center">
              <h4 class="text-center my-5">
                {{ $i18n.t('stories.shared_in.title_share_again') }}
              </h4>
              <v-btn
                  class="mb-5 align-self-center"
                  max-width="133"
                  rounded
                  outlined
                  color="primary"
                  elevation="0"
                  @click="openShareDialog"
              >
                <v-icon left>mdi-redo</v-icon>
                {{ $i18n.t('stories.shared_in.share_button') }}
              </v-btn>
            </div>
          </v-col>
        </v-row>
      </div>
    </v-menu>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import Avatar from '../../Elements/Avatar'
import Search from "../../Elements/Forms/Search";

export default {
  components: {
    Search,
    Avatar
  },
  data: () => ({
    displaySwitcher: false,
    search: '',
  }),
  computed:{
    isShared(){
      return this.story.publication?.attributes?.shareType == 'shared'
    },
    ...mapState({
      story: state => state.stories.story
    }),
    publicationsWithFamily() {
      return this.story.publications.map((publication) => {
        publication.community = this.story.communities
            .find((community) => community.id === publication.relationships.family.data.id)
        return publication
      })
    }
  },
  methods: {
    ...mapActions({
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
      setDialog: 'layout/setDialog'
    }),
    toggleMenu() {
      if (!this.isShared) {
        this.displaySwitcher = false
        this.setDialog({
          component: 'ShareStoryDialog',
          title: this.$i18n.t('stories.share_modal.with_family.title'),
          size: 'big'
        })
      } else {
        this.displaySwitcher = !this.displaySwitcher
      }
    },
    async unShareItem (publicationId) {
      this.setDialog({
        component: 'StoryDeleteDialog',
        title: this.$i18n.t('stories.unshare_title'),
        size: 'big',
        data: {
          publicationId
        }
      })
    },
    openShareDialog() {
      this.setDialog({
        component: 'ShareStoryDialog',
        title: this.$i18n.t('stories.share_modal.with_family.title'),
        size: 'big'
      })
      this.toggleMenu()
    },
    handleSearch() {}
  }
}
</script>

<style lang="scss" scoped>
.shared-in-menu {
  border-radius: 5px;
  box-shadow: none;
  &:before,
  &:after {
    content: "";
    position: absolute;
    width: 0;
    height: 0;
    border-style: solid;
    border-color: transparent;
    border-bottom: 0;
  }
  &:before {
    top: 0;
    right: 55px;
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-bottom: 8px solid $color-primary;
  }
  &:after {
    top: 1px;
    right: 56px;
    width: 0;
    height: 0;
    border-left: 7px solid transparent;
    border-right: 7px solid transparent;
    border-bottom: 7px solid $color-dark-white;
  }
  &__wrapper {
    background: $color-dark-white;
    border: 1px solid $color-primary;
    border-radius: 5px;
    margin-top: 10px;
    overflow: hidden;
    padding: 8px 8px 0 8px;
  }
  &__list {
    background-color: transparent;
    max-height: 306px;
    overflow-y: scroll;
  }
  &__title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 26px;
  }
  &__link {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 26px;
    color: $color-tertiary;
    &--more.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      font-family: Lato;
      font-style: normal;
      font-weight: bold;
      font-size: 16px;
      line-height: 26px;
      color: $color-primary !important;
      justify-content: center;
    }
  }
  &__sidebar {
    min-width: 310px;
    max-height: 300px;
    overflow-y: auto;
  }
  &__search {

  }
  &__back-button {
    position: absolute;
    right: 16px;
    z-index: 1;
  }
}
</style>
