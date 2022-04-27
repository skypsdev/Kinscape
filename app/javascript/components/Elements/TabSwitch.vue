<template>
  <div
    v-if="!isMobile"
    class="d-flex flex-row align-center justify-center fill-height"
  >
    <template v-for="button in buttons">
      <Tooltip
        v-if="button.tooltip"
        v-bind="button.tooltip"
        :key="button.label"
      >
        <template #activator="{ attrs }">
          <v-btn
            v-bind="attrs"
            rounded
            :outlined="!isCurrentPath(button.to.name)"
            :color="button.activeColor ? button.activeColor : 'primary'"
            elevation="0"
            class="tab-switch__button mx-2"
            :to="button.to"
            :id="button.id"
            :title="$i18n.t(button.title)"
          >
            <v-badge
              v-if="$$(button,'badge')"
              color="secondary"
              :content="button.badge"
            >
              {{ $i18n.t(button.label) }}
            </v-badge>
            <template v-else>
              {{ $i18n.t(button.label) }}
            </template>
          </v-btn>
        </template>
      </Tooltip>
      <v-btn
        v-else
        :key="button.label"
        rounded
        :outlined="!isCurrentPath(button.to.name)"
        :color="button.activeColor ? button.activeColor : 'primary'"
        elevation="0"
        class="tab-switch__button mx-2"
        :id="button.id"
        :to="button.to"
        :title="$i18n.t(button.title)"
      >
        <v-badge
          v-if="$$(button,'badge')"
          color="secondary"
          :content="button.badge"
        >
          {{ $i18n.t(button.label) }}
        </v-badge>
        <template v-else>
          {{ $i18n.t(button.label) }}
        </template>
      </v-btn>
    </template>
  </div>
  <v-menu
    v-else
    v-model="displaySwitcher"
    content-class="tab-switch__wrapper"
    offset-y
    bottom
    dense
  >
    <template #activator="{ attrs, on }">
      <v-btn
        v-bind="attrs"
        color="primary"
        elevation="0"
        rounded
        large
        v-on="on"
      >
        {{ $i18n.t(activeButton.label) }}
        <v-icon class="ml-2">
          mdi-chevron-down
        </v-icon>
      </v-btn>
    </template>

    <v-list dense class="tab-switch__list">
      <v-list-item
        v-for="button in buttons"
        :key="button.label"
        :to="button.to"
        exact-path
      >
        {{ $i18n.t(button.label) }}
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script>
import Tooltip from '@/components/Elements/Tooltip.vue'
import breakpointsMixin from '@/mixins/breakpointsMixin'

export default {
  components: {
    Tooltip
  },
  mixins: [breakpointsMixin],
  props: {
    buttons: {
      type: Array,
      required: true
    },
    simulatePath: {
      type: Boolean,
      default: false
    }
  },
  data: () => ({
    displaySwitcher: false,
  }),
  computed: {
    activeButton() {
      return this.buttons.find(({ to }) => this.isCurrentPath(to.name)) || {}
    }
  },
  methods: {
    isCurrentPath(name) {
      return this.simulatePath ? this.simulatePath === name : this.$route.name === name
    }
  }
}
</script>
<style lang="scss" scoped>
.tab-switch {
  &__button {
    min-width: 100px !important;
  }

  &__wrapper {
    background: $color-dark-white;
    border: 1px solid $color-primary;
    border-radius: 5px;
    margin-top: 10px;
    overflow: hidden;
  }
}
</style>
