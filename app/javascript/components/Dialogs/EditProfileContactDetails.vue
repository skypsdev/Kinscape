<template>
  <DialogContent
    class="edit-profile-dialog"
    title="Edit Profile Contact Details"
    @close="$emit('close')"
    :header="false"
  >
    <template v-slot:content>
      <div class="profile-grid" v-if="items">
        <h2 class="edit-profile-dialog__header">
          {{ $i18n.t('profile.edit.dialog_title') }}
        </h2>
        <vuuri
          ref="vuuri"
          class="vuuri-container"
          v-model="gridItems"
          :get-item-width="getItemWidth"
          :get-item-height="getItemHeight"
          :options="vuuriOptions"
          @layoutEnd="reorder"
          item-key="id"
          drag-enabled
        >
          <template #item="{ item }">
            <ProfileContactDetailEditCard
              ref="profileCard"
              :item="item"
              :name="item.name"
              :type="item.type"
              :title="item.title"
              :label="item.label ? item.label : item.name"
              :deletable="item.deletable"
              :icon="item.icon"
              @removeCard="removeCard"
              @updateCard="updateCard"
              @vuuriUpdate="updateLayout()"
            />
          </template>
        </vuuri>
      </div>

      <v-container class="add-attributes">
        <h2 class="mt-10 mb-8">
          {{ $i18n.t('profile.edit.add_custom_attribute_title') }}
        </h2>
        <v-row>
          <v-card class="add-attributes__card pa-4 mr-4" elevation="0">
            <div class="d-flex justify-space-between align-center mt-4 mb-2">
              <div class="d-flex">
                <v-icon color="medium_grey">mdi-tag-outline</v-icon>
                <h2 class="add-attributes__card-title">
                  {{ $i18n.t('profile.edit.add_custom_text') }}
                </h2>
              </div>
              <v-btn
                color="primary"
                plain
                x-small
                elevation="0"
                @click="createCard(newCardName)"
              >
                <v-icon color="primary" class="mr-1" small
                  >mdi-plus-circle-outline</v-icon
                >
                {{ $i18n.t('profile.edit.add') }}
              </v-btn>
            </div>
            <v-text-field
              background-color="white"
              v-model="newCardName"
              placeholder="Type title"
              outlined
              hide-details
            />
          </v-card>
          <v-card class="add-attributes__card pa-4" elevation="0">
            <div class="d-flex justify-space-between align-center mt-4 mb-2">
              <div class="d-flex">
                <v-icon color="medium_grey">mdi-calendar</v-icon>
                <h2 class="add-attributes__card-title">
                  {{ $i18n.t('profile.edit.add_custom_date') }}
                </h2>
              </div>
              <v-btn
                color="primary"
                plain
                x-small
                elevation="0"
                @click="createDateCard()"
              >
                <v-icon class="mr-1" small>mdi-plus-circle-outline</v-icon>
                {{ $i18n.t('profile.edit.add') }}
              </v-btn>
            </div>
            <div class="d-flex">
              <DatePicker
                background-color="white"
                value=""
                :showCalendarIcon="false"
                @input="(value) => (newDateCardValue = value)"
              />
            </div>
          </v-card>
        </v-row>
      </v-container>
    </template>
    <template v-slot:actions>
      <v-btn
        class="edit-profile-dialog__button"
        color="primary"
        elevation="0"
        large
        rounded
        outlined
        @click="$emit('close')"
      >
        {{ $i18n.t('profile.edit.dialog.controls.cancel') }}
      </v-btn>
      <v-btn
        class="edit-profile-dialog__button v-btn--active"
        color="primary"
        elevation="0"
        large
        rounded
        outlined
        @click="confirm"
      >
        {{ $i18n.t('profile.edit.dialog.controls.save') }}
      </v-btn>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import _ from 'lodash'
import vuuri from 'vuuri'

import DialogContent from '../Layout/Dialog/DialogContent'
import ProfileContactDetailEditCard from '../Profiles/ProfileContactDetailEditCard'
import DatePicker from '../Elements/Forms/DatePicker'

export default {
  components: {
    vuuri,
    DialogContent,
    ProfileContactDetailEditCard,
    DatePicker
  },
  props: {
    order: {
      type: Array,
      required: false
    },
    items: {
      type: Array,
      required: true
    },
    toggle: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      newCardName: '',
      newDateCardValue: '',
      gridItems: _.cloneDeep(this.items),
      profileOrder: [],
      vuuriOptions: {
        dragStartPredicatate: {
          distance: 500,
          delay: 500
        }
      }
    }
  },
  computed: {
    ...mapState({
      member: (store) => store.members.member
    })
  },
  watch: {
    toggle() {
      this.updateLayout()
    }
  },
  mounted() {
    this.updateLayout()
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError'
    }),
    getItemWidth(item) {
      return item.width ? item.width + 'px' : '31%'
    },
    getItemHeight(item) {
      return item.height + 'px'
    },
    getItemById(id) {
      return this.gridItems.find((item) => item.id == id)
    },
    createCard() {
      const label = 'Custom text'
      this.gridItems.push({
        id: this.gridItems.length,
        label: label,
        name: 'custom',
        title: this.$i18n.t('profile.edit.add_custom_text'),
        deletable: true,
        value: [
          {
            label: 'Custom text',
            type: 'text',
            id: this.gridItems.length,
            value: [{ type: 'text', value: this.newCardName }]
          }
        ]
      })

      this.$refs.vuuri.update()
    },
    createDateCard() {
      const label = 'Custom date'
      this.gridItems.push({
        id: this.gridItems.length,
        label: label,
        name: 'custom_date',
        title: this.$i18n.t('profile.edit.add_custom_date'),
        type: 'date',
        deletable: true,
        value: [
          {
            label: 'Custom date',
            type: 'date',
            value: [{ type: 'date', value: this.newDateCardValue }]
          }
        ]
      })
      this.$refs.vuuri.update()
    },
    removeCard(item) {
      const index = this.gridItems.findIndex((value) => value.id === item.id)
      this.$delete(this.gridItems, index)
    },
    updateCard(payload) {
      const item = this.getItemById(payload.id)
      item.value = payload.value
    },
    confirm() {
      const profileAttrs = {
        profileAttrsOrder: this.profileOrder
      }
      this.gridItems
        .filter((item) => item.value.length)
        .forEach((card) => {
          if (card.value[0]?.value[0]?.value.length) {
            profileAttrs[card.name] = card.value
          }
        })

      this.$emit('submit', profileAttrs)
    },
    reorder(items) {
      this.profileOrder = items.map((item) => {
        return parseInt(item._element.getAttribute('data-item-key'))
      })
    },
    updateLayout() {
      setTimeout(() => {
        this.$refs.vuuri.update()
      }, 500)
    }
  }
}
</script>

<style lang="scss">
.edit-profile-dialog {
  background: $color-dark-white !important;

  &__header {
    color: $color-tertiary;
    font-size: 16px;
    margin: 16px 0 10px 0;
  }

  &__button {
    width: 132px !important;
  }

  .profile-grid {
    margin: 0 -5px;
  }

  .dialog__footer {
    background: #fff;

    &.v-card__actions {
      padding: 24px;
    }
  }
}

.add-attributes {
  &__card {
    border-radius: 0;
    width: 320px;

    &:before {
      background: $color-medium-grey;
      @include pseudo($height: 1px, $width: 100%);
    }

    &-title {
      color: $color-grey;
      font-family: Lato;
      font-size: 16px;
      font-weight: bold;
      padding: 0 0 0 20px;
    }
  }

  &__card.v-card {
    background: transparent;
  }
}
</style>
