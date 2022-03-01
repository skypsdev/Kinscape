<template>
  <v-menu
    v-model="model"
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
        v-for="(item, index) in items"
        :key="`menu-${_uid}-option-${index}`"
        @click="handleClick(item) && item.action"
      >
        {{ item.title }}
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script>
export default {
  props: {
    elevation: { type: Number, default: 0 },
    toggle: { type: Boolean, required: true },
    items: { type: [Array, Object], required: true },
    theme: {
      type: String,
      default: 'default',
      validator: (value) => ['default', 'toolbar', 'orange'].includes(value)
    }
  },
  computed: {
    model: {
      get() {
        return this.toggle
      },
      set(value) {
        return this.$emit('toggled', value)
      }
    }
  },
  methods: {
    handleClick(item) {
      this.$emit(item.action, item)
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
