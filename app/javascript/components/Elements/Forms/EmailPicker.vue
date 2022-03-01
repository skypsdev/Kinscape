<template>
  <v-combobox
      ref="emailPicker"
      class="email-picker"
      v-model="model"
      item-value="text"
      hide-selected
      hide-details
      outlined
      multiple
      :delimiters="[',']"
  >
    <template v-slot:selection="{ attrs, item, parent, selected }">
      <v-chip
          class="email-picker__tag"
          v-bind="attrs"
          :color="isValidEmail(item) ? 'secondary_lightest' : 'error'"
          :input-value="selected"
          label
      >
        <v-icon :color="isValidEmail(item) ? 'black' : 'white'" small @click="parent.selectItem(item)">
          mdi-close
        </v-icon>
        <span class="pl-2" :class="isValidEmail(item) ? 'black--text' : 'white--text'">
          {{ item }}
        </span>
      </v-chip>
    </template>
  </v-combobox>
</template>

<script>
export default {
  props: {
    value: {
      type: Array,
      default: () => []
    },
  },
  data: () => ({
    model: []
  }),
  watch: {
    async model (val) {
      this.$emit('input', val)
      if (val.length) {
        let isInputValid = true
        for (const email of val) {
          const isValid = this.isValidEmail(email)
          if (!isValid && isInputValid) {
            isInputValid = false
          }
        }
        this.$emit('validate', isInputValid)
      }
    },
  },
  mounted() {
    this.model = this.value
  },
  methods: {
    isValidEmail(email) {
      // eslint-disable-next-line no-control-regex
      const emailRegex = new RegExp('(?:[a-z0-9!#$%&\'*+/=?^_`{|}~-]+(?:\\.[a-z0-9!#$%&\'*+/=?^_`{|}~-]+)*|"(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21\x23-\x5b\x5d-\x7f]|\\\\[\x01-\x09\x0b\x0c\x0e-\x7f])*")@(?:(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\x01-\x08\x0b\x0c\x0e-\x1f\x21-\x5a\x53-\x7f]|\\\\[\x01-\x09\x0b\x0c\x0e-\x7f])+)\\])')
      return emailRegex.test(email)
    },
  }
}
</script>

<style lang="scss" scoped>
.email-picker {
  &::v-deep {
    .v-select__selections {
      padding: 6px 0 !important;
      min-height: 48px;
    }
    .v-input__append-inner {
      display: none;
    }
  }
  &__item {
    border-bottom: 0.6px solid $color-disabled !important;
    display: flex;
    align-items: center;
    width: 100%;
    margin-left: 8px;
    margin-right: 8px;
    &--first {
      border-bottom: none !important;
      display: flex;
      align-items: center;
      width: 100%;
      margin-left: 8px;
      margin-right: 8px;
    }
  }
  &__tag {
    border-radius: 80px !important;
    font-weight: bold;
    font-size: 12px !important;
    line-height: 180%;
    color: $color-tertiary !important;
    max-height: 28px;
  }
  &__meta {
    color: $color-tertiary !important;
    opacity: 0.72;
    font-weight: bold;
    font-size: 12px;
    line-height: 180%;
  }
  &__create {
    color: $color-primary !important;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;
  }
}
</style>
