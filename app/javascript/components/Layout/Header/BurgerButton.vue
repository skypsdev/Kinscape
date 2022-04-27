<template>
  <v-menu
    bottom
    offset-y
  >
    <template v-slot:activator="{ on, attrs }">
      <v-tooltip
        v-model="burgerTip"
        content-class="burger-button secondary_dark"
        nudge-left="176px"
        bottom
      >
        <div
          class="pa-6"
        >
          <v-btn
            class="burger-button__close"
            color="white"
            icon
            @click="onClickOutside"
          >
            <v-icon>
              mdi-close
            </v-icon>
          </v-btn>

          <div class="burger-button__title">
            Tour Kinscape here.
          </div>
          <div class="burger-button__description">
            You can also take a Tour from the main dropdown menu at any time.
          </div>
          <div class="text-right">
            <v-btn
              class="burger-button__tour"
              elevation="0"
              rounded
              large
              @click.stop="showTour"
            >
              Go to Kinscape's Tour
            </v-btn>
          </div>
        </div>

        <template #activator="{ attrs: tooltipAttrs }">
          <v-btn
            class="hidden-sm-and-down"
            :class="{
              'primary_lighter--text': burgerTip,
              'secondary_dark': burgerTip
            }"
            icon
            v-bind="{ ...attrs, ...tooltipAttrs }"
            v-on="on"
          >
            <v-icon>mdi-menu</v-icon>
          </v-btn>
        </template>
      </v-tooltip>
    </template>
    <v-list dense>
      <v-list-item href="/account">
        <v-list-item-content>
          <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.account') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item href="/subscriptions">
        <v-list-item-content>
          <v-list-item-title class="pr-2 new-paying-member-cvr-btn">{{ $i18n.t('user_menu.manage_subscription') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item @click.stop="showTour">
        <v-list-item-content>
          <v-list-item-title class="pr-2">{{ 'Take Tour' }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item
        link
        target="_blank"
        href="https://intercom.help/kinscape"
      >
        <v-list-item-content>
          <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.help_center') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item href="/sign_out">
        <v-list-item-content>
          <v-list-item-title class="pr-2">{{ $i18n.t('user_menu.sign_out') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  computed: {
    ...mapGetters({
      activeTooltip: 'core/activeTooltip'
    }),
    burgerTip: {
      get() {
        return this.activeTooltip === 'burger'
      },
      set(flag) {
        if (!flag) {
          this.closeTooltip('burger')
        }
      }
    }
  },
  methods: {
    ...mapActions({
      closeTooltip: 'core/closeTooltip'
    }),
    showTour() {
      this.onClickOutside()
      
      localStorage.setItem('tour', true)
      if (this.$route.name != 'communities') {
        this.$router.push('/communities')
      } else {
        this.$eventBus.emit('show-tour')
      }
    },
    onClickOutside() {
      this.closeTooltip('burger')
    }
  }
}
</script>


<style lang="scss">
.burger-button.v-tooltip__content {
  opacity: 1;
  border-radius: 5px;
  box-shadow: 0 10px 20px #0002;

  width: 400px;
  height: 180px;
  padding: 0;

  color: white;
  line-height: 24px;
  pointer-events: all;
  z-index: 1000 !important;

  .burger-button__title {
    font-weight: bold;
    font-size: 18px;
    margin-bottom: 12px;
  }
  .burger-button__description {
    font-weight: 400;
    font-size: 16px;
    margin-bottom: 4px;
  }
  .burger-button__tour {
    color: white;
    background-image: linear-gradient(98.51deg, #e95631 6.21%, #8b78fe 90.22%);
    font-size: 18px;
  }

  .burger-button__close {
    position: absolute;
    top: 8px;
    right: 8px;
  }
}
</style>
