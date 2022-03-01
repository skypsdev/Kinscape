<template>
  <div class="picker d-flex flex-row" :class="isInThePast ? 'picker--error' : ''">
    <v-col class="d-flex align-center justify-start">
      <v-checkbox
          class="picker__checkbox ml-3 mt-0 pt-0"
          v-model="form.isVisible"
          hide-details
          :label="$i18n.t('placeholders.story.in_future')"
          @change="updateDate()"
      />
    </v-col>
    <v-col cols="6">
      <div v-if="form.isVisible" class="d-flex align-center ml-4">
        <v-icon>mdi-calendar-range</v-icon>
        <v-text-field
            v-model="form.year"
            type="number"
            :min="new Date().getFullYear()"
            hide-details
            outlined
            class="date-selector date-selector--year ml-2"
            :placeholder="$i18n.t('placeholders.story.year')"
            @change="updateDate()"
            @click="updateDate()"
        />
        <v-select
            v-model="form.month"
            hide-details
            outlined
            class="date-selector date-selector--month ml-2"
            :placeholder="$i18n.t('placeholders.story.month')"
            :disabled="!form.year"
            :items="months"
            @change="updateDate()"
        />
        <v-select
            v-model="form.day"
            hide-details
            outlined
            class="date-selector date-selector--day ml-2"
            :placeholder="$i18n.t('placeholders.story.day')"
            :disabled="!form.year || !form.month"
            :items="endDays"
            @change="updateDate()"
        />
      </div>
    </v-col>
    <v-col>
      <p v-if="isInThePast">
        <v-icon class="mr-1">mdi-alert-circle</v-icon>
        <span class="picker__error-text">{{ $i18n.t('errors.story.date.in_the_past') }}</span>
      </p>
    </v-col>
  </div>
</template>

<script>

export default {
  data () {
    return {
      form: {
        year: '',
        month: '',
        day: '',
        isVisible: false,
      },
      months: this.$moment.months()
    }
  },
  computed: {
    endDays () {
      const {year, month} = this.form
      const days = this.$moment(`${year}-${month}`, "YYYY-MMMM").daysInMonth()
      return days ? [ ...Array(days).keys() ].map( i => (i+1).toString()) : []
    },
    isInThePast() {
      return this.$moment(`${this.form.day} ${this.form.month} ${this.form.year}`).isBefore(this.$moment())
    }
  },
  mounted() {
    this.setNowDate()
  },
  methods: {
    updateDate() {
      if (!this.form.isVisible) {
        this.setNowDate()
      }
      this.$emit('validate', { error: this.isInThePast })
      this.$emit('changeDate', this.form)
    },
    setNowDate() {
      const date = this.$moment()
      this.form.year = date.year()
      this.form.month = this.months[date.month()]
      this.form.day = (date.date()+1).toString()
    }
  }
}
</script>

<style lang="scss">
.picker {
  padding: 20px;
  width: 100%;

  &--error {
    background: #FFE9EE;
    border: 1px solid #DF1642;
    box-sizing: border-box;
    border-radius: 5px;
    .picker__error-text {
      font-style: normal;
      font-weight: 600;
      font-size: 14px;
      line-height: 17px;
      color: #DF1642;
    }
  }
  &__checkbox {
    .v-label {
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

