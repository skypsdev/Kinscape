<template>
  <div class="community-description-edit">
    <div
        class="community-description-edit__label mb-2"
        v-text="$i18n.t('placeholders.family.name')"
    />
    <v-text-field
        class="community-description-edit__input"
        v-model="form.name"
        outlined
        hide-details
        single-line
        color="primary"
        type="text"
        @keydown="handleChange"
    />

    <div
        class="community-description-edit__label mt-6 mb-2"
        v-text="$i18n.t('placeholders.family.motto')"
    />
    <v-text-field
        class="community-description-edit__input"
        v-model="form.motto"
        outlined
        hide-details
        single-line
        color="primary"
        type="text"
        @keydown="handleChange"
    />

    <div
        class="community-description-edit__label mt-6 mb-2"
        v-text="$i18n.t('placeholders.family.description')"
    />
    <v-textarea
        class="community-description-edit__input"
        v-model="form.description"
        outlined
        @keydown="handleChange"
    />
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import debounce from 'lodash/debounce'

export default {
  data () {
    return {
      form: {
        name: '',
        description: '',
        motto: ''
      }
    }
  },
  computed: {
    ...mapState({
      community: store => store.families.community
    })
  },
  mounted() {
    const {name, description, motto} = this.community
    this.form = {name, description, motto}
  },
  methods: {
    ...mapActions({
      updateCommunity: 'families/updateCommunity'
    }),
    handleChange() {
      this.saveCommunityChanges(this)
    },
    saveCommunityChanges: debounce((ctx) => {
      ctx.updateCommunity({
        id: ctx.community.id,
        form: {...ctx.form}
      })
    }, 700)
  }
}
</script>

<style lang="scss">
.community-description-edit {
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
}
</style>

