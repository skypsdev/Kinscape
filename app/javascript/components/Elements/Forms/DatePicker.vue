<template>
  <div class="d-flex align-center justify-start">
    <v-icon v-if="showCalendarIcon" class="mr-2">mdi-calendar-range</v-icon>
    <v-text-field
      v-model="form.startYear"
      type="number"
      :min="1"
      :max="form.endYear || 3000"
      hide-details
      outlined
      :class="`date-selector date-selector--year date-selector--${size}`"
      :placeholder="$i18n.t('placeholders.story.year')"
      @change="updateDate()"
      @click="updateDate()"
      dense
      :background-color="backgroundColor"
    />

    <v-select
      v-model="form.startMonth"
      hide-details
      outlined
      :class="`date-selector date-selector--month ml-2 date-selector--${size}`"
      :placeholder="$i18n.t('placeholders.story.month')"
      :disabled="!form.startYear"
      :items="months"
      @change="updateDate()"
      :background-color="backgroundColor"
    />

    <v-select
      v-model="form.startDay"
      hide-details
      outlined
      :class="`date-selector date-selector--day ml-2 date-selector--${size}`"
      :placeholder="$i18n.t('placeholders.story.day')"
      :disabled="!form.startYear || !form.startMonth"
      :items="startDays"
      @change="updateDate()"
      :background-color="backgroundColor"
    />
  </div>
</template>
<script>
export default {
  props: {
    value: {
      required: true
    },
    showCalendarIcon: {
      type: Boolean,
      default: true
    },
    placeholder: {
      type: String,
      required: false
    },
    rules: {
      type: Array,
      required: false
    },
    size: {
      type: String,
      default: 'small'
    },
    backgroundColor: {
      type: String,
      required: false
    }
  },
  data() {
    return {
      form: {
        startYear: '',
        startMonth: '',
        startDay: ''
      },
      months: this.$moment.months()
    }
  },
  computed: {
    startDays() {
      const { startYear, startMonth } = this.form
      const days = this.$moment(
        `${startYear}-${startMonth}`,
        'YYYY-MMMM'
      ).daysInMonth()
      return days ? [...Array(days).keys()].map((i) => (i + 1).toString()) : []
    }
  },
  mounted() {
    const date = this.$moment(this.value)
    this.form.startYear = this.$moment(date).year()
    this.form.startMonth = this.$moment(date).format('MMMM')
    this.form.startDay = this.$moment(date).format('D')
  },
  methods: {
    parseFormDate(year, month, day) {
      return this.$moment(`${year}-${month}-${day}`, 'YYYY-MMMM-D').format(
        'YYYY-MM-DD'
      )
    },
    updateDate() {
      const { startYear, startMonth, startDay } = this.form
      const start = this.parseFormDate(startYear, startMonth, startDay)
      this.$emit('input', start)
      this.$emit('changeDate')
    }
  }
}
</script>

<style lang="scss" scoped>
.date-selector {
  &::v-deep .v-text-field {
    color: $color-tertiary;
    &--outlined fieldset {
      border-color: $color-light-grey;
    }
  }
  &--year {
    min-width: 68px;
    max-width: 78px;
  }
  &--month {
    max-width: 136px;
  }
  &--day {
    max-width: 78px;
  }
  &--x-small {
    &::v-deep .v-input__control {
      height: 32px !important;

      .v-input__append-inner {
        margin-top: 0 !important;
      }
    }
  }
  &::v-deep .v-select__selections {
    padding: 0 !important;
  }
  &::v-deep .v-select.v-select__selection--comma {
    margin: 0 !important;
  }
  &::v-deep .v-input__slot {
    padding: 0 6px !important;
  }
}
</style>
