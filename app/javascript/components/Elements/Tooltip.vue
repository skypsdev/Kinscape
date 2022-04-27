<template>
  <v-tooltip
    v-bind="{...$attrs, ...nudge}"
    v-on="$listeners"
    v-model="show"
    :content-class="contentClass"
    :top="position.startsWith('top')"
    :left="position === 'left'"
    :right="position === 'right'"
    :bottom="position.startsWith('bottom')"
  >
    <div class="pa-10" v-click-outside="onClickOutside">
      <v-btn
        class="tooltip__close"
        icon
        @click="closeTooltip(name)"
      >
        <v-icon>
          mdi-close
        </v-icon>
      </v-btn>
      <div class="tooltip__title mb-4">
        <v-avatar
          v-for="icon in icons"
          :key="icon"
          class="tertiary mr-1"
          size="28px"
        >
          <v-icon color="white" size="sm">
            {{ icon }}
          </v-icon>
        </v-avatar>

        <span class="ml-3">
          {{ title }}
        </span>
      </div>

      <div class="tooltip__description">
        {{ description }}
      </div>
    </div>

    <template v-for="(_, slot) in $scopedSlots" v-slot:[slot]="props">
      <slot :name="slot" v-bind="props" />
    </template>
  </v-tooltip>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  props: {
    name: {
      type: String,
      required: true
    },
    icons: {
      type: Array,
      default: () => []
    },
    title: {
      type: String,
      default : ''
    },
    description: {
      type: String,
      default: ''
    },
    position: {
      type: String,
      default: ''
    }
  },
  computed: {
    ...mapGetters({
      activeTooltip: 'core/activeTooltip'
    }),
    nudge () {
      if (this.position === 'bottom left' || this.position === 'top left') {
        return {
          'nudge-left': '33.333%'
        }
      } else if (this.position === 'top right' || this.position === 'bottom right') {
        return {
          'nudge-right': '33.333%'
        }
      }
      return {}
    },
    contentClass () {
      const baseClass = 'tooltip secondary_lightest tertiary--text'

      switch (this.position) {
      case 'bottom left':
        return baseClass + ' tooltip--bottom-left'
      case 'bottom right':
        return baseClass + ' tooltip--bottom-right'
      case 'top left':
        return baseClass + ' tooltip--top-left'
      case 'top right':
        return baseClass + ' tooltip--top-right'
      case 'left':
        return baseClass + ' tooltip--left'
      case 'right':
        return baseClass + ' tooltip--right'
      }

      return ''
    },
    show: {
      get () {
        // prevent when tour is active
        if(localStorage.getItem('tour'))return false

        return this.activeTooltip === this.name
      },
      set (flag) {
        if (!flag) {
          this.closeTooltip(this.name)
        }
      }
    }
  },
  methods: {
    ...mapActions({
      closeTooltip: 'core/closeTooltip'
    }),
    onClickOutside () {
      this.closeTooltip(this.name)
    }
  }
}
</script>

<style lang="scss">
.tooltip {
  padding: 0;
  opacity: 1;
  width: 350px;
  box-shadow: none;
  pointer-events: all;
  filter: drop-shadow(0, 5px, 10px, #53489820);
  z-index: 1000 !important;

  &:before {
    content: '';
    position: absolute;
    width: 16px;
    height: 16px;

    background-color: #E8E4FF;
    transform: translate(-50%, -50%) rotate(45deg);
  }

  &.tooltip--bottom-left:before {
    top: 0;
    right: 33.333%;
  }
  &.tooltip--bottom-right:before {
    top: 0;
    left: 33.333%;
  }
  &.tooltip--top-left:before {
    bottom: 0;
    right: 33.333%;
  }
  &.tooltip--top-right:before {
    bottom: 0;
    left: 33.333%;
  }
  &.tooltip--left:before {
    right: 0;
    top: 50%;
  }
  &.tooltip--right:before {
    left: 0;
    top: 50%;
  }

  .tooltip__title {
    font-family: Enriqueta;
    font-weight: 700;
    font-size: 18px;
    line-height: 23px;
  }

  .tooltip__description {
    font-family: Lato;
    font-weight: 400;
    font-size: 16px;
    line-height: 23px;
  }

  .tooltip__close {
    position: absolute;
    top: 8px;
    right: 8px;
  }
}
</style>
