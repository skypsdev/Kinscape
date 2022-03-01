<template>
  <div>
    <OptionsDropdownMenu
        :nudge-left="188"
        :nudge-bottom="42"
    >
      <template v-slot:activator="{ on }">
        <v-btn
            class="member__more"
            fab
            outlined
            small
            color="secondary"
            elevation="0"
            :v-on="on"
        >
          <v-icon>mdi-dots-horizontal</v-icon>
        </v-btn>
      </template>
      <template v-slot:content>
        <v-row no-gutters>
          <v-col class="member__sidebar">
            <v-list dense class="member__list pb-0">
              <div
                  v-for="(item, index) in switcherItems"
                  :key="index"
                  class="pb-4"
              >
                <v-list-item
                    v-if="item.title"
                    class="member__title"
                    @click="initiateAction(item)"
                >
                  {{ item.title }}
                </v-list-item>
                <v-divider v-if="item.id === 'divider'"/>
              </div>
            </v-list>
          </v-col>
        </v-row>
      </template>
    </OptionsDropdownMenu>
  </div>
</template>
<script>
import OptionsDropdownMenu from "../../Elements/OptionsDropdownMenu";
import { mapActions } from "vuex";

export default {
  components: { OptionsDropdownMenu },
  props: {
    member: {
      type: Object,
      required: true,
    },
  },
  computed: {
    switcherItems() {
      return [
        {
          id: 'cancelInvitation',
          title: this.$i18n.t('communities.invitations.cancel_invitation'),
          action: 'sendCancelInvitation'
        },
        {
          id: 'resendInvitation',
          title: this.$i18n.t('communities.invitations.resend'),
          action: 'sendResendInvitation'
        }
      ]
    },
  },
  methods: {
    ...mapActions({
      cancelInvitation: 'families/cancelInvitations',
      resendInvitation: 'families/resendInvitations',
    }),
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
    sendCancelInvitation() {
      this.cancelInvitation([this.member.id])
    },
    sendResendInvitation() {
      this.resendInvitation([this.member.id])
    }
  }
}
</script>
<style lang="scss" scoped>
.member {
  &__more {
    position: absolute;
    right: 2px;
    top: 0;
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
