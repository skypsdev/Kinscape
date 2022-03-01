<template>
  <v-row class="chip-select px-md-3 py-4" no-gutters>
    <v-col
        v-for="item in items"
        :key="item.id"
        cols="12"
        md="3"
        class="px-2 py-1"
    >
      <v-chip
          class="chip-select__chip w--100"
          :disabled="loading"
          large
          :input-value="isSelected(item)"
          :color="isSelected(item) ? '#FCD0C4' : 'transparent'"
          text-color="black"
          @click="toggleSelection(item)"
      >
        <span class="chip-select__avatar-wrapper mr-3">
          <v-img
              v-if="isSelected(item)"
              contain
              class="chip-select__checkmark"
              :src="require('../../../assets/images/checkmark.svg')"
          />
          <Avatar
              class="chip-select__avatar"
              :class="isSelected(item) ? 'chip-select__avatar--is-selected' : ''"
              :src="item.image || require('../../../assets/images/image-placeholder.svg')"
          />
        </span>
        <span class="chip-select__label">
          {{ item.name }}
        </span>
      </v-chip>
    </v-col>
  </v-row>
</template>
<script>
import Avatar from "../Avatar";

export default {
  components: {
    Avatar,
  },
  props: {
    value: {
      type: Array,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    loading: {
      type: Boolean,
      default: false
    },
  },
  data: () => ({
    selectedItems: [],
  }),
  watch: {
    selectedItems () {
      this.$emit('input', this.selectedItems)
    },
  },
  methods: {
    toggleSelection(item) {
      if (this.isSelected(item)) {
        this.removeFromSelected(item)
      } else {
        this.addToSelected(item)
      }
    },
    addToSelected(item) {
      if (!this.isSelected(item)) {
        this.selectedItems.push(item)
      }
    },
    removeFromSelected(item) {
      this.selectedItems = this.selectedItems.filter(filterItem => filterItem.id !== item.id)
    },
    isSelected(item) {
      return this.selectedItems.filter(filterItem => filterItem.id === item.id).length > 0
    },
  }
}
</script>
<style lang="scss" scoped>
.chip-select {
  min-height: 162px;
  max-height: 176px;
  overflow-y: scroll;
  background-color: #F7F7F7;
  border-radius: 5px;
  &__chip {
    &::before {
      opacity: 0;
    }
  }
  &__label {
    font-family: Lato, sans-serif;
    font-style: normal;
    font-weight: bolder;
    font-size: 16px;
    line-height: 20px;
  }
  &__avatar-wrapper {
    display: grid;
    justify-items: center;
  }
  &__avatar {
    grid-area: 1 / 1;
    &--is-selected {
      border: 2px solid #E75739;
    }
  }
  &__checkmark {
    grid-area: 1 / 1;
    z-index: 7;
  }
}
::v-deep .v-chip .v-avatar {
  height: 42px !important;
  width: 42px !important;
  min-width: 42px !important;
}

::v-deep .theme--light.v-icon {
  color: #E75739
}

::v-deep .v-text-field--outlined > .v-input__control > .v-input__slot fieldset {
  color: $color-required !important;
}

::v-deep .v-text-field--outlined.v-input--is-focused fieldset {
  border: 1px solid $color-required;
}
</style>
