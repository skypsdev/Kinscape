<template>
  <v-card class="edit-card" elevation="0" ref="cardEl">
    <div class="edit-card__header">
      <div class="edit-card__label">
        <v-icon class="edit-card__icon" color="tertiary">
          {{ icon }}
        </v-icon>
        <div class="edit-card__title">
          {{ title }}
        </div>
      </div>
      <v-btn
        v-if="allowGroups"
        @click="addGroup(label)"
        class="edit-card__add-group px-0"
        elevation="0"
        plain
        x-small
      >
        <v-icon color="primary" small>mdi-plus-circle-outline</v-icon>&nbsp;
        {{ `${$i18n.t('profile.edit.add')} ${title}` }}
      </v-btn>
    </div>

    <div class="edit-card__groups">
      <div v-for="(group, index) in groups" :key="`group-${index}`">
        <ContactDetailsCardGroup
          :group="group"
          :options="name === 'place_of_birth' ? false : defaultOptions"
          :name="name"
          :type="type"
          :icon="icon"
          :label="group.title"
          @addGroupType="addGroupType"
          @removeGroup="removeGroup(index)"
          @changeLabel="(label) => changeLabel(label, index)"
          @onUpdate="update"
        />
      </div>
    </div>
    <v-icon
      v-if="deletable"
      class="edit-card__delete"
      @click="$emit('removeCard', item)"
      small
      >mdi-delete</v-icon
    >
  </v-card>
</template>

<script>
import _ from 'lodash'
import ContactDetailsCardGroup from './ContactDetailsCardGroup.vue'
import formDefaults from './ProfileContactDetailsDefaults'

export default {
  components: {
    ContactDetailsCardGroup
  },
  props: {
    item: { type: Object },
    label: { type: String, required: true },
    icon: { type: String, default: 'mdi-account-outline' },
    name: { type: String, default: 'default' }, // emails, addresses, default etc
    type: { type: String, default: 'text' },
    title: { type: String, default: 'text' },
    deletable: { type: Boolean, default: false }
  },
  data: () => ({
    groups: [],
    options: [],
    allowGroups: true
  }),
  computed: {
    model: {
      get() {
        return this.item
      },
      set(value) {
        this.$emit('updateCard', {
          value: value,
          id: this.item.id
        })
      }
    },
    defaultFields() {
      const defaults = formDefaults[this.name]
      if (defaults) {
        const value = defaults.value.map((field) => {
          return {
            name: field.name,
            value: ''
          }
        })
        return value
      }

      return [{ name: this.label, value: '' }]
    },
    defaultOptions() {
      const defaults = formDefaults[this.name]?.options
      const options = [
        ...(defaults
          ? defaults.map((option) => ({
              ...option,
              action: 'changeLabel'
            }))
          : []),
        {
          control: 'input',
          title: `+ ${this.$i18n.t('profile.edit.options.create_custom_type')}`,
          action: 'addGroupType',
          targetAction: 'changeLabel'
        }
      ]
      return options
    }
  },
  mounted() {
    if (this.model.value.length) {
      this.groups = this.model.value
    } else {
      this.addGroup(this.label)
    }
    this.allowGroups = !['place_of_birth', 'birth_date'].includes(this.model.name)
    this.options = this.defaultOptions
  },
  methods: {
    addGroup(label) {
      const group = {
        id: this.groups.length,
        title: label,
        value: _.cloneDeep(this.defaultFields),
        type: this.type
      }
      this.groups.push(group)
      this.$emit('vuuriUpdate')
    },
    addGroupType(item) {
      this.options.push({
        title: item.title,
        action: 'changeLabel',
        control: false
      })
    },
    removeGroup(index) {
      this.groups.splice(index, 1)
      this.$emit('vuuriUpdate')
    },
    update() {
      this.model = this.groups
    },
    changeLabel(label, index) {
      this.groups[index].title = label
    }
  }
}
</script>

<style lang="scss">
.edit-card {
  background: white;
  border-radius: 15px;
  min-height: 144px;
  position: relative;
  padding: 35px 19px 19px 19px !important;
  transition: height 200ms ease-out, filter 200ms ease-out;

  &::before {
    @include pseudo($width: 20px, $height: 20px);
    background-color: $color-dark-white;
    background-image: url('../../assets/images/icons/draggable.svg');
    background-position: center center;
    left: 10px;
    top: 10px;
  }

  &__header {
    display: flex;
    justify-content: space-between;
  }

  &__label {
    align-items: center;
    color: $color-tertiary;
    display: flex;
    font-size: 13px !important;
    font-weight: bold;
    margin: 0;
  }

  &__icon.v-icon {
    margin-right: 7px;
  }

  &__title {
    font-size: 16px;
  }

  &__group {
    &-header {
      display: flex;
      justify-content: space-between;
      margin: 10px 0 5px 0;
    }

    &-type {
      background: #f7f7f7;
      color: $color-primary !important;
      font-size: 13px;
      font-weight: 400;

      &:before {
        background: #f7f7f7;
      }

      .v-btn__content {
        padding-right: 15px;

        &:after {
          @include pseudo($width: 0, $height: 0);
          border-style: solid;
          border-color: $color-primary transparent transparent transparent;
          border-width: 5px 4px 0 4px;
          right: 0;
        }
      }
    }
  }

  &__add-group.v-btn {
    color: $color-primary;
  }

  &__delete {
    position: absolute !important;
    top: 10px;
    right: 10px;
  }

  &--big {
    height: 128px;
  }

  .v-text-field > .v-input__control > .v-input__slot {
    font-size: 14px;
    padding: 5px 10px !important;
    margin-bottom: 5px;

    .v-text-field__details {
      display: none;
    }
  }

  .v-text-field.v-text-field--enclosed .v-text-field__details {
    display: none;
  }
}

.vuuri-container {
  .muuri-item {
    cursor: move;
    margin: 7px;

    &-dragging {
      .edit-card.v-sheet {
        border: 1px solid $color-primary !important;
        filter: drop-shadow(0px 10px 20px rgba(0, 0, 0, 0.16));
      }
    }
  }

  &::v-deep {
    .muuri-item-placeholder {
      opacity: 0.5;
      margin: 0 !important;
    }
  }
}
</style>
