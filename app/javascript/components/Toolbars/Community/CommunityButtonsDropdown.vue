<template>
  <div>
    <v-menu
        bottom
        offset-y
        nudge-left="100"
        v-model="displaySwitcher"
        content-class="dropdown-button"
        :close-on-content-click="false"
    >
      <template v-slot:activator="{ attrs }">
        <div
            class="dropdown-button__activator"
            @click="toggleSwitcher"
        >
          <v-btn
              fab
              small
              rounded
              outlined
              color="primary"
              elevation="0"
              class="mx-1"
              height="32"
              width="32"
              v-bind="attrs"
          >
            <v-icon>mdi-dots-horizontal</v-icon>
          </v-btn>
        </div>
      </template>
      <div class="dropdown-button__wrapper">
        <v-row no-gutters>
          <v-col class="dropdown-button__sidebar">
            <v-list dense class="dropdown-button__list pb-0">
              <div
                  v-for="(item, index) in switcherItems"
                  :key="index"
                  class="pb-4"
              >
                <v-list-item
                    v-if="item.title"
                    class="dropdown-button__title"
                    @click="initiateAction(item)"
                >
                  {{ item.title }}
                </v-list-item>
                <v-divider v-if="item.id === 'divider'"/>
              </div>
            </v-list>
          </v-col>
        </v-row>
      </div>
    </v-menu>
  </div>
</template>
<script>
import breakpointsMixin from "../../../mixins/breakpointsMixin";
import {mapActions} from "vuex";

export default {
  mixins: [
    breakpointsMixin
  ],
  data: () => ({
    displaySwitcher: false,
  }),
  computed: {
    communityId() {
      return this.$route.params.id
    },
    switcherItems() {
      return [
        {
          id: 'addMember',
          title: this.$i18n.t('offline_member.add_member'),
          href: `/communities/${this.communityId}/offline_members/new`
        },
        {
          id: 'openInviteToCommunityDialog',
          title: this.$i18n.t('invitations.family_member.title'),
          action: 'openInviteToCommunityDialog'
        },
        {
          id: 'divider'
        },
        {
          id: 'openDeleteCommunityDialog',
          title: this.$i18n.t('families.remove'),
          action: 'openDeleteCommunityDialog'
        }
      ]
    },
    selectedItem() {
      return this.switcherItems.find(item => item.id === this.$route.name)
    },
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    toggleSwitcher() {
      this.displaySwitcher = !this.displaySwitcher
    },
    initiateAction(item) {
      if(item.href) {
        this.goToItem(item)
      } else {
        this[item.action]()
      }
    },
    goToItem(item) {
      window.location.href = item.href
    },
    openDeleteCommunityDialog() {
      this.setDialog({
        component: 'CommunityDeleteDialog',
        title: this.$i18n.t('confirmation_dialog.title')
      })
    },
    openInviteToCommunityDialog() {
      this.setDialog({
        component: 'CommunityInviteDialog',
        title: this.$i18n.t('invitations.family_member.title')
      })
    }
  }
}
</script>
<style lang="scss" scoped>
.dropdown-button {
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
    right: 20px;
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-bottom: 8px solid $color-primary;
  }
  &:after {
    top: 1px;
    right: 21px;
    width: 0;
    height: 0;
    border-left: 7px solid transparent;
    border-right: 7px solid transparent;
    border-bottom: 7px solid $color-dark-white;
  }
  &__activator {
    display: flex;
    &::v-deep .v-input__slot {
      cursor: pointer !important;
    }
  }
  &__wrapper {
    background: $color-dark-white;
    border: 1px solid $color-primary;
    border-radius: 5px;
    margin-top: 10px;
    overflow: hidden;
  }
  &__list {
    background-color: transparent;
    max-height: 80vh;
    overflow-y: auto;
  }
  &__title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
    font-size: 16px;
    line-height: 16px;
    font-style: normal;
    font-weight: 600;
    color: $color-text !important;
  }
  &__title {
    padding-left: 30px;
  }
  &__link {
    min-height: 32px;
    padding-left: 32px;
    font-weight: bold;
    font-size: 16px;
    color: #4B4B4B;
    &--active.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      background-color: #FCD0C4;
      color: $color-primary !important;
    }
    &--more.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      font-weight: bold;
      font-size: 16px;
      line-height: 26px;
      color: $color-primary !important;
      justify-content: flex-end;
    }
  }
  &__sidebar-title.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
    padding-left: 30px;
    font-weight: bold;
    font-size: 18px;
    line-height: 26px;
    color: $color-primary !important;
  }
  &__sidebar {
    min-width: 220px;
    max-height: 700px;
    overflow-y: auto;
  }
}
</style>
