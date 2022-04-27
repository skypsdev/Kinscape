<template>
  <v-menu
    v-bind="$attrs"
    v-on="$listeners"
    :content-class="`menu menu--${theme} elevation-${elevation}`"
    :close-on-content-click="false"
    :nudge-bottom="5"
    :elevation="0"
    offset-y
    left
  >
    <template v-slot:activator="{ on, attrs }">
      <slot name="activator" :on="on" :attrs="attrs" />
    </template>

    <v-list class="menu__list">
      <v-list-item
        class="menu__item"
        v-for="(item, index) in options"
        :key="`menu-${_uid}-option-${index}`"
        @click="handleClick(item)"
      >
        <template v-if="item.title">
          {{ item.title }}
        </template>
        <template v-else>
          <slot name="item" :item="item" />
        </template>
      </v-list-item>

      <v-list-item-group v-for="(item, index) in controls" :key="index">
        <v-list-item
          class="menu__item menu__item--highlighted"
          @click="showControl = !showControl"
        >
          {{ item.title }}
        </v-list-item>

        <template v-if="showControl && item.control === 'input'">
          <div class="pt-4 px-4">
            <v-text-field
              v-model="newTextFieldValue"
              :placeholder="
                $i18n.t('profile.edit.fields.placeholders.create_custom_type')
              "
              ref="newTextField"
              class="mb-2"
              @keyup.esc="cancelControl(item)"
              @keyup.enter="confirmControl(item)"
              outlined
              hide-details
              x-small
            />
            <div class="d-flex align-center justify-center py-1">
              <v-btn
                color="primary"
                x-small
                @click="cancelControl(item)"
                plain
                >{{ $i18n.t('profile.edit.options.option_cancel') }}</v-btn
              >
              <v-btn
                color="primary"
                x-small
                @click="confirmControl(item)"
                :disabled="!newTextFieldValue.length"
                plain
                >{{ $i18n.t('profile.edit.options.option_save') }}</v-btn
              >
            </div>
          </div>
        </template>
      </v-list-item-group>
    </v-list>
  </v-menu>
</template>

<script>
export default {
  props: {
    elevation: { type: Number, default: 0 },
    items: { type: [Array, Object], required: true },
    theme: {
      type: String,
      default: 'default',
      validator: (value) => ['default', 'toolbar', 'orange'].includes(value)
    }
  },
  data: () => ({
    showControl: false,
    newTextFieldValue: ''
  }),
  computed: {
    options() {
      return this.items.filter((item) => !item.control)
    },
    controls() {
      return this.items.filter((item) => item.control)
    }
  },
  watch: {
    showControl(value) {
      if (value) {
        this.$nextTick(() => {
          this.$refs.newTextField[0].focus()
        })
      }
    }
  },
  methods: {
    handleClick(item) {
      if (item.control) {
        this.$emit(item.action, {
          title: this.newTextFieldValue
        })
      } else if (item.action) {
        this.$emit(item.action, item)
        this.model = false
      } else {
        this.$emit('action', item)
      }

      this.showControl = false
    },
    cancelControl() {
      this.showControl = false
      this.newTextFieldValue = ''
    },
    confirmControl(item) {
      this.$emit(item.action, {
        title: this.newTextFieldValue,
        action: item.targetAction,
        control: false
      })
      this.showControl = false
    }
  }
}
</script>

<style lang="scss">
.menu {
  border: 1px solid $color-grey;
  box-sizing: border-box;
  border-radius: 8px;
  width: 240px;

  &.elevation-1 {
    box-shadow: 0px 4px 8px 2px rgba(0, 0, 0, 0.16) !important;
  }

  &__list {
    padding: 10px 0;

    &.v-sheet {
      background-color: $color-dark-white;
    }
  }

  &__item {
    font-size: 16px;
    min-height: auto;
    padding: 4px 15px;

    &:hover {
      background: $color-secondary-lightest;
    }
  }

  /** Vueitfy important overrides */
  .theme--light.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
    color: $color-text !important;

    &.menu__item--highlighted {
      color: $color-primary !important;
    }
  }

  &--orange {
    border-color: $color-primary;

    .menu__item {
      &:hover {
        background: #fcd0c4;
      }
    }

    .theme--light.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      color: $color-primary !important;
    }
  }

  &--toolbar {
    border-color: $color-primary;

    .menu__item {
      &:hover {
        background: #fcd0c4;
      }
    }

    .theme--light.v-list-item:not(.v-list-item--active):not(.v-list-item--disabled) {
      color: $color-text !important;
    }
  }
}
</style>
