<template>
  <div class="date-rang-picker">
    <div class="d-flex align-center justify-start">
      <v-icon>mdi-calendar-range</v-icon>
      <v-text-field
        v-model="form.startYear"
        type="number"
        :min="1"
        :max="form.endYear || 3000"
        hide-details
        outlined
        class="date-selector date-selector--year ml-2"
        :placeholder="$i18n.t('placeholders.story.year')"
        @change="updateDate()"
        @click="updateDate()"
      />

      <v-select
        v-model="form.startMonth"
        hide-details
        outlined
        class="date-selector date-selector--month ml-2"
        :placeholder="$i18n.t('placeholders.story.month')"
        :disabled="!form.startYear"
        :items="months"
        @change="updateDate()"
      />

      <v-select
        v-model="form.startDay"
        hide-details
        outlined
        class="date-selector date-selector--day ml-2"
        :placeholder="$i18n.t('placeholders.story.day')"
        :disabled="!form.startYear || !form.startMonth"
        :items="startDays"
        @change="updateDate()"
      />
    
      <v-checkbox
        class="date-rang-picker__checkbox ml-3 mt-0 pt-0"
        v-model="form.isRange"
        hide-details
        :label="$i18n.t('placeholders.story.range')"
        @change="handleIsRange"
      />
    </div>
    <div
      v-if="form.isRange"
      class="d-flex align-center mt-2"
    >
      <v-icon>mdi-calendar-range</v-icon>
      <v-text-field
        v-model="form.endYear"
        type="number"
        :min="form.startYear || 1000"
        :max="3000"
        hide-details
        outlined
        class="date-selector date-selector--year ml-2"
        :placeholder="$i18n.t('placeholders.story.year')"
        @change="updateDate(true)"
        @click="updateDate(true)"
      />
    
      <v-select
        v-model="form.endMonth"
        hide-details
        outlined
        class="date-selector date-selector--month ml-2"
        :placeholder="$i18n.t('placeholders.story.month')"
        :disabled="!form.endYear"
        :items="months"
        @change="updateDate(true)"
      />
    
      <v-select
        v-model="form.endDay"
        hide-details
        outlined
        class="date-selector date-selector--day ml-2"
        :placeholder="$i18n.t('placeholders.story.day')"
        :disabled="!form.endYear || !form.endMonth"
        :items="endDays"
        @change="updateDate(true)"
      />
    </div>
  </div>
</template>

<script>

export default {
  props: {
    story: {
      type: Object,
      default: () => ({})
    }
  },
  data () {
    return {
      form: {
        startYear: '',
        endYear: '',
        startMonth: '',
        endMonth: '',
        startDay: '',
        endDay: '',
        isRange: false,
      },
      months: this.$moment.months()
    }
  },
  computed: {
    startDays () {
      const {startYear, startMonth} = this.form
      const days = this.$moment(`${startYear}-${startMonth}`, "YYYY-MMMM").daysInMonth()
      return days ? [ ...Array(days).keys() ].map( i => (i+1).toString()) : []
    },
    endDays () {
      const {endYear, endMonth} = this.form
      const days = this.$moment(`${endYear}-${endMonth}`, "YYYY-MMMM").daysInMonth()
      return days ? [ ...Array(days).keys() ].map( i => (i+1).toString()) : []
    },
  },
  mounted() {
    const {startYear, endYear, startMonth, endMonth, startDay, endDay, isRange} = this.story
    this.form.isRange = isRange || false
    this.form.startYear = startYear || this.$moment().year()
    this.form.startMonth = startMonth || this.$moment().format('MMMM')
    this.form.startDay = startDay || this.$moment().format('D')
    this.form.endYear = isRange && endYear ? endYear : ''
    this.form.endMonth = isRange && endMonth ? endMonth : ''
    this.form.endDay = isRange && endDay ? endDay : ''
  },
  methods: {
    parseFormDate(year, month, day) {
      return this.$moment(`${year}-${month}-${day}`, "YYYY-MMMM-D")
    },
    handleIsRange() {
      const {isRange, startYear,startMonth, startDay} = this.form
      this.form.endYear = isRange ? startYear : ''
      this.form.endMonth = isRange ? startMonth : ''
      this.form.endDay = isRange ? startDay : ''
      this.updateDate()
    },
    updateDate(isEnd) {
      const {startYear, endYear, startMonth, endMonth, startDay, endDay} = this.form
      const start = this.parseFormDate(startYear, startMonth, startDay).valueOf()
      const end = this.parseFormDate(endYear, endMonth, endDay).valueOf()
      if (start > end) {
        if (isEnd) {
          this.form.startYear = endYear
          this.form.startMonth = endMonth
          this.form.startDay = endDay
        } else {
          this.form.endYear = startYear
          this.form.endMonth = startMonth
          this.form.endDay = startDay
        }
      }
      
      this.$emit('changeDate')
    }
  }
}
</script>

<style lang="scss">
.date-rang-picker {
  &__checkbox {
    .v-label {
      font-family: Lato;
      font-style: normal;
      font-weight: bold;
      font-size: 12px;
      line-height: 14px;
      color: #4B4B4B;
    }
  }
  .date-selector {
    height: 32px;
    &.v-text-field {
      color: #4B4B4B;
      &--outlined fieldset {
        border-color: $color-light-grey;
      }
    }
    &--year {
      max-width: 80px;
    }
    &--month {
      max-width: 136px;
    }
    &--day {
      max-width: 78px;
    }
    &.v-select.v-text-field--outlined .v-select__selections {
      padding: 0 !important;
    }
    &.v-select.v-select__selection--comma {
      margin: 0 !important;
    }
    &.v-text-field .v-input__slot {
      padding-right: 6px !important;
    }
  }
}
</style>

