<template>
  <v-combobox
    ref="comboboxInput"
    class="combobox"
    v-model="model"
    :filter="filter"
    :hide-no-data="!search"
    :items="tags"
    item-value="text"
    :search-input.sync="search"
    hide-selected
    hide-details
    outlined
    multiple
  >
    <template v-slot:no-data>
      <v-list-item>
        <div class="combobox__item--first">
          <v-chip
            class="combobox__tag"
            color="secondary_lightest"
            label
          >
            {{ search }}
          </v-chip>
          <v-spacer/>
          <span
            @click="$refs.comboboxInput.blur()"
            class="combobox__create"
            v-text="$i18n.t('stories.create_category')"
          />
        </div>
      </v-list-item>
    </template>
    <template v-slot:selection="{ attrs, item, parent, selected }">
      <v-chip
        v-if="item === Object(item)"
        class="combobox__tag"
        v-bind="attrs"
        color="secondary_lightest"
        :input-value="selected"
        label
      >
        <v-icon small @click="parent.selectItem(item)">
          mdi-close
        </v-icon>
        <span class="pl-2">
          {{ item.text }}
        </span>
      </v-chip>
    </template>
    <template v-slot:item="{ item }">
      <div class="combobox__item">
        <v-chip
          class="combobox__tag"
          color="secondary_lightest"
          label
        >
          {{ item.text }}
        </v-chip>
        <v-spacer></v-spacer>
        <v-list-item-action
          class="combobox__meta"
          @click.stop
        >
          {{ item.number }} {{$i18n.t('stories.other_stories')}}
        </v-list-item-action>
      </div>
    </template>
  </v-combobox>
</template>

<script>
export default {
  props: {
    items: {
      type: Array,
      default: () => []
    },
    selected: {
      type: Array,
      default: () => []
    }
  },
  data: () => ({
    tags: [
      //{ header: 'Select an option or create one' }
    ],
    model: [],
    search: null
  }),
  computed: {
    selectedItems() {
      return this.model.map((item) => item.text)
    }
  },
  watch: {
    model (val, prev) {
      if (val.length === prev.length) return
      this.model = val.map(v => {
        if (typeof v === 'string') {
          v = {
            text: v,
            number: 0
          }
          this.tags.push(v)
        }
        return v
      })
      if (val.length !== this.selected.length) {
        this.$emit('changeSelection')
      }
    },
  },
  mounted() {
    this.tags = this.items
    this.model = this.selected
  },
  methods: {
    filter (item, queryText, itemText) {
      if (item.header) return false

      const hasValue = val => val != null ? val : ''

      const text = hasValue(itemText)
      const query = hasValue(queryText)

      return text.toString()
        .toLowerCase()
        .indexOf(query.toString().toLowerCase()) > -1
    },
  },
}
</script>

<style lang="scss" scoped>
  .combobox {
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
