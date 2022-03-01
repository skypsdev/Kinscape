<template>
  <DialogContent>
    <template v-slot:content>
      <div class="px-10">
        <v-form
          @submit.prevent
          ref="addBoxForm"
          v-model="isFormValid"
        >
          <h4
            class="add-box__label d-inline-block mt-10 mr-3"
            v-text="$i18n.t('vaults.box.name_your_box')"
          />
          <p
            class="add-box__label--required d-inline-block mb-3"
            v-text="'* '+$i18n.t('vaults.box.required')"
          />
          <v-text-field
            v-model="form.name"
            :rules="[rules.required]"
            :placeholder="$i18n.t('vaults.box.untitled_box')"
            autofocus
            class="add-box__input"
            outlined
            single-line
            color="primary"
            type="text"
            @keyup.enter="submitForm()"
          />
        </v-form>
      </div>

    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          large
          rounded
          outlined
          color="primary"
          elevation="0"
          class="ma-2"
          min-width="170"
          @click="closeDialog()"
        >
          {{ $i18n.t('vaults.nav.buttons.cancel') }}
        </v-btn>
        <v-btn
          large
          rounded
          color="primary"
          elevation="0"
          class="ma-2"
          min-width="170"
          :disabled="isLoading"
          @click="submitForm()"
        >
          {{ $i18n.t('vaults.nav.buttons.create') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import rules from '../../utils/validators'
import { mapActions, mapState } from 'vuex'
export default {
  components: {
    DialogContent
  },
  data: () => ({
    rules,
    isFormValid: false,
    form: {
      name: ''
    }
  }),
  computed: {
    ...mapState({
      dialog: state => state.layout.dialog,
      isLoading: state => state.vaults.loading
    })
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      addVaultBox: 'vaults/addVaultBox'
    }),
    submitForm() {
      this.$refs.addBoxForm.validate()
      if (this.isFormValid) {
        const { vaultId, parentBoxId } = this.dialog.data
        this.addVaultBox(
          {
            vaultId,
            params: {
              ...this.form,
              parentBoxId: parentBoxId || null
            }
          }
        )
      }
    }
  }
}
</script>

<style lang="scss" scoped>
.add-box {
  &__input::v-deep.v-text-field {
    font-size: 18px;
    color: #4b4b4b;
    .v-input__control {
      min-height: 48px !important;
    }
    .v-input__slot {
      min-height: 48px !important;
    }
    .v-label {
      top: 6px !important;
    }
  }
  &__label {
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $color-text;
    &--required {
      font-weight: bold;
      font-size: 12px;
      line-height: 14px;
      color: $color-required;
    }
  }
}
</style>
