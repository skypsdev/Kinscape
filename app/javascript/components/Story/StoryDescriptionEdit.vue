<template>
  <div class="story-description-edit">
    <div
      class="story-description-edit__label mb-2"
      v-text="$i18n.t('placeholders.story.title')"
    />
    <v-text-field
      class="story-description-edit__input"
      v-model="form.title"
      outlined
      hide-details
      single-line
      color="primary"
      type="text"
      @keydown="handleChange"
    />

    <div
      class="story-description-edit__label mt-4 mb-2"
      v-text="$i18n.t('placeholders.story.categories')"
    />
    <Combobox
      ref="Categories"
      :selected="story.categories"
      :items="allCategories"
      @changeSelection="handleChange"
    />

    <div
      class="story-description-edit__label mt-6 mb-2"
      v-text="$i18n.t('stories.newStoryDialog.storyDescriptionLabel')"
    />
    <v-textarea
      class="story-description-edit__input"
      v-model="form.description"
      outlined
      @keydown="handleChange"
    />
    <DateRangePicker
      ref="DateRangPicker"
      @changeDate="handleChange"
      :story="story"
    />
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import debounce from 'lodash/debounce'
import DateRangePicker from '../Elements/Forms/DateRangePicker'
import Combobox from '../Elements/Forms/Combobox'

export default {
  components: {DateRangePicker, Combobox},
  data () {
    return {
      form: {
        title: '',
        description: ''
      }
    }
  },
  computed: {
    ...mapState({
      story: store => store.stories.story,
      allCategories: store => store.stories.allCategories
    })
  },
  mounted() {
    const {title, description} = this.story
    this.form = {title, description}
  },
  methods: {
    ...mapActions({
      updateStory: 'stories/updateStory'
    }),
    handleChange() {
      this.saveStoryChanges(this)
    },
    saveStoryChanges: debounce((ctx) => {
      const {story, form, $refs, updateStory} = ctx
      updateStory({
        id: story.publication.id,
        form: {
          story: {
            ...form,
            ...$refs.DateRangPicker.form,
            categories: $refs.Categories.selectedItems
          }
        }
      })
    }, 700)
  }
}
</script>

<style lang="scss">
.story-description-edit {
  &__label {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: #4B4B4B
  }
  &__input {
    &.v-text-field {
      font-size: 18px;
      color: #4B4B4B;
      .v-input__control {
        min-height: 48px !important;
      }
      .v-input__slot {
        min-height: 48px !important;
      }
      .v-label {
        top: 6px !important;
      }
      &--outlined fieldset {
        border-color: $color-light-grey;
      }
    }
  }
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
      width: 60px;
    }
    &--month {
      width: 116px;
    }
    &--day {
      width: 75px;
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

