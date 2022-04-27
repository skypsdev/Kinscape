<template>
  <div class="edit-card__group">
    <div class="edit-card__group-header">
      <template v-if="options">
        <Menu
          v-if="name !== 'birth_date'"
          v-model="menuOpen"
          theme="toolbar"
          :items="options"
          :elevation="1"
          @changeLabel="(value) => changeLabel(value)"
          @addGroupType="(value) => $emit('addGroupType', value)"
        >
          <template v-slot:activator="{ on, attrs }">
            <v-btn
              class="edit-card__group-type"
              v-bind="attrs"
              v-on="on"
              elevation="0"
              x-small
            >
              {{ label }}
            </v-btn>
          </template>
        </Menu>
        <v-btn
          class="float-right"
          x-small
          plain
          v-if="label !== $i18n.t(`date_types.birth_date`)"
        >
          <v-icon
            @click="(value) => $emit('removeGroup', value)"
            color="primary"
            small
            >mdi-minus-circle-outline</v-icon
          >
        </v-btn>
      </template>
    </div>

    <div
      v-for="(field, fieldIndex) in group.value"
      :key="fieldIndex"
    >
      <template v-if="type === 'date'">
        <DatePicker
          class="ml-n2"
          :value="field.value"
          :showCalendarIcon="false"
          size="x-small"
          @input="(value) => changeDate(field, value)"
        />
      </template>
      <template v-else>
        <v-text-field
          :type="field.type"
          :placeholder="
            $i18n.t(
              `profile.edit.fields.placeholders.${
                field.name ? field.name.replace(/ /g, '') : 'Customtext'
              }`
            )
          "
          v-model="field.value"
          outlined
          x-small
          hide-details
          @input="updateField"
          @blur="updateField"
        />
      </template>
    </div>
  </div>
</template>

<script>
import Menu from '../Menu/Menu'
import DatePicker from '../Elements/Forms/DatePicker.vue'

export default {
  components: {
    Menu,
    DatePicker
  },
  props: {
    options: {
      type: [Array, Boolean],
      required: true
    },
    group: {
      type: Object,
      required: true
    },
    name: {
      type: String,
      required: true
    },
    type: {
      type: String,
      required: true
    },
    label: {
      type: String,
      required: false
    },
    icon: {
      type: String,
      required: false
    }
  },
  data: () => ({
    menuOpen: false
  }),
  methods: {
    changeLabel(option) {
      this.menuOpen = false
      this.$emit('changeLabel', option.title)
      this.updateField()
    },
    updateField() {
      this.$emit('onUpdate', this.group)
    },
    changeDate(field, value) {
      field.value = value
      this.updateField()
    }
  }
}
</script>

<style lang="scss">
.edit-card__group {
  .v-text-field__slot input {
    padding: 0 !important;
  }
}
</style>
