<template>
  <DialogContent>
    <template v-slot:content>
      <v-container>
        <v-form ref="editMemberForm" v-model="isValid">
          <div
              v-for="(attribute, attributeIndex) in form"
              :key="attributeIndex.toString()"
              class="mt-4"
          >
            <v-row no-gutters>
              <h4 class="edit-member__heading f--tertiary d-inline-block mb-2">
                {{ $i18n.t(`communities.member.edit.dialog.${attributeIndex}`) }}
              </h4>
              <v-btn
                  v-if="!isString(attribute)"
                  text
                  class="edit-member__btn ml-auto mr-0"
                  @click="addItem(attributeIndex)"
              >
                <v-icon size="16" color="primary">mdi-plus-circle-outline</v-icon>
                <span class="ml-1">
                {{ $i18n.t(`communities.member.edit.dialog.${attributeIndex}_add`) }}
                </span>
              </v-btn>
            </v-row>
            <v-row no-gutters>
              <v-text-field
                  v-if="isString(attribute)"
                  :placeholder="$i18n.t(`communities.member.edit.dialog.${attributeIndex}_placeholder`)"
                  v-model="form[attributeIndex]"
                  outlined
                  single-line
                  hide-details
                  color="primary"
                  type="text"
                  height="48"
              />
              <div v-else v-for="(item, itemIndex) in attribute" :key="itemIndex" class="d-flex flex-column w--100">
                <div>
                  <v-text-field
                      v-model="item.name"
                      class="edit-member__label-edit pt-0"
                      single-line
                      hide-details
                      color="primary"
                      type="text"
                  >
                    <template v-slot:prepend-inner>
                      <v-icon size="16" color="#E75739">mdi-pencil</v-icon>
                    </template>
                  </v-text-field>
                </div>
                <v-row class="mt-0" no-gutters>
                  <v-col cols="11" class="pt-1">
                    <v-text-field
                        :placeholder="$i18n.t(`communities.member.edit.dialog.${attributeIndex}_placeholder`)"
                        v-model="item.value"
                        outlined
                        single-line
                        color="primary"
                        type="text"
                        height="48"
                    />
                  </v-col>
                  <v-col
                      v-if="itemIndex > 0"
                      class="justify-end"
                  >
                    <v-btn
                        text
                        @click="removeItem(attributeIndex, itemIndex)"
                    >
                      <v-icon color="primary">mdi-minus-circle-outline</v-icon>
                    </v-btn>
                  </v-col>
                </v-row>
              </div>
            </v-row>
            <v-divider />
          </div>
        </v-form>
      </v-container>
    </template>
    <template v-slot:actions>
      <v-btn
          x-large
          rounded
          outlined
          color="primary"
          elevation="0"
          class="ma-1 mr-6"
          @click="closeDialog"
      >
        {{ $i18n.t('communities.edit.cancel') }}
      </v-btn>
      <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1 px-4"
          :disabled="isLoading"
          @click="sendPayload"
      >
        {{ $i18n.t('communities.edit.save') }}
      </v-btn>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'

export default {
  components: {
    DialogContent
  },
  data: () => ({
    isLoading: false,
    isValid: false,
    form: {
      emails: [{
        name: 'Email',
        value: '',
      }],
      addresses: [{
        name: 'Address',
        value: '',
      }],
      phone_numbers: [{
        name: 'Phone Number',
        value: '',
      }],
      locations: [{
        name: 'Location',
        value: '',
      }],
      place_birth: '',
      birth_date: '',
      facebook: '',
      instagram: '',
      website: ''
    },
  }),
  computed: {
    ...mapState({
      member: state => state.members.member,
    }),
  },
  mounted() {
    // deep copy the member object
    this.form = JSON.parse(JSON.stringify({ ...this.member.profile }))
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
      updateMember: 'members/updateMember',
    }),
    sendPayload() {
      this.isLoading = true
      this.updateMember({ id: this.member.id, form: { profileAttrs: { ...this.form } } })
          .then(() => {
            this.closeDialog()
          })
          .catch((error) => {
            this.setError(error)
          })
          .finally(() => {
            this.isLoading = false
          })
    },
    isString(value) {
      return typeof value === 'string'
    },
    addItem(attributeIndex) {
      this.form[attributeIndex].push({
        name: this.$i18n.t('communities.member.edit.dialog.set_type'),
        value: '',
        isEditing: false
      })
    },
    removeItem(attributeIndex, itemIndex) {
      this.form[attributeIndex].splice(itemIndex, 1)
    },
  }
}
</script>
<style lang="scss" scoped>
.edit-member {
  &__heading {
    font-family: Lato;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-tertiary;
  }
  &__btn {
    font-family: Lato;
    font-weight: bold;
    font-size: 13px;
    line-height: 26px;
    text-align: right;
    color: $color-primary;
  }
  &__label {
    height: 32px;
    font-size: 16px;
    line-height: 24px;
    text-decoration-line: underline;
    color: $color-primary;
  }
  &__label-edit {
    &::v-deep .v-input__slot:before {
      border: none;
    }
    &::v-deep .v-input__slot:after {
      border: none;
    }
    &::v-deep .v-input__slot {
      padding: 0 !important;
    }
    &::v-deep input {
      text-decoration: underline;
      color: $color-primary;
    }
  }
}

::v-deep .v-label {
  font-family: Lato;
  font-style: normal;
  font-weight: bold;
  font-size: 12px;
  line-height: 14px;
}
</style>
