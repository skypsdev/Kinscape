<template>
  <v-menu
      v-if="selectedItem"
      bottom
      offset-y
      v-model="displaySwitcher"
      content-class="dropdown-button"
      close-on-content-click
    >
      <template v-slot:activator="{ attrs }">
        <div
            class="dropdown-button__activator"
            @click="toggleSwitcher"
        >
          <v-btn
              rounded
              color="primary"
              elevation="0"
              v-bind="attrs"
              block
          >
            {{ selectedItem.title }}
            <v-icon class="mt-1">{{displaySwitcher ? 'mdi-chevron-up' : 'mdi-chevron-down'}}</v-icon>
          </v-btn>
        </div>
      </template>
      <div class="dropdown-button__wrapper">
        <v-row no-gutters>
          <v-col
              class="dropdown-button__sidebar"
          >
            <v-list dense class="dropdown-button__list pb-0">
              <div
                  v-for="(item, index) in switcherItems"
                  :key="index"
                  class="pb-4"
              >
                <v-list-item
                    v-if="item.title"
                    class="dropdown-button__title"
                    @click="goToItem(item)"
                >
                  {{ item.title }}
                </v-list-item>
              </div>
            </v-list>
          </v-col>
        </v-row>
      </div>
    </v-menu>
</template>
<script>
export default {
  props: {
    simulatePath: {
      type: String,
      default: ''
    },
    communityId: {
      type: String,
      default: ''
    },
  },
  data: () => ({
    displaySwitcher: false,
  }),
  computed: {
    switcherItems() {
      return [
        {
          id: 'showFamily',
          title: 'Profile',
        },
        {
          id: 'members',
          title: 'Members',
        },
        {
          id: 'invitedMembers',
          title: 'Invitations',
        },
        {
          id: 'communityVault',
          title: 'Vault',
        }
      ]
    },
    selectedItem() {
      return this.switcherItems.find(item => this.isCurrentPath(item.id))
    },
  },
  methods: {
    toggleSwitcher() {
      this.displaySwitcher = !this.displaySwitcher
    },
    goToItem(item) {
      const route = { name: item.id }
      if (this.communityId) {
        route.params = { id: this.communityId }
      }
      this.$router.push(route)
    },
    isCurrentPath(name) {
      return this.simulatePath ? this.simulatePath === name : this.$route.name === name
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
    right: 27px;
    width: 0;
    height: 0;
    border-left: 8px solid transparent;
    border-right: 8px solid transparent;
    border-bottom: 8px solid $color-primary;
  }
  &:after {
    top: 1px;
    right: 28px;
    width: 0;
    height: 0;
    border-left: 7px solid transparent;
    border-right: 7px solid transparent;
    border-bottom: 7px solid $color-dark-white;
  }
  &__activator {
    width: 100%;
    max-width: 133px;
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
    font-weight: bold;
    font-size: 14px;
    line-height: 26px;
    color: $color-primary !important;
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
    min-width: 133px;
    min-height: 136px;
    max-height: 700px;
    overflow-y: auto;
  }
}
</style>
