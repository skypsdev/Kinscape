<template>
  <v-text-field
    v-model="search"
    class="search-form"
    rounded
    dense
    outlined
    hide-details
    single-line
    color="primary"
    clearable
    :label="placeholder"
    type="text"
    prepend-inner-icon="mdi-magnify"
    @keydown="handleSearch"
    @click:clear="handleSearch"
  />
</template>

<script>
import debounce from 'lodash/debounce'

export default {
  props: {
    searchTerm: {
      type: String,
      default: ''
    },
    placeholder: {
      type: String,
      default: function() { return this.$i18n.t('placeholders.search')}
    }
  },
  data: ()=>({
    search: ''
  }),
  watch:{
    searchTerm(query) {
      this.search = query
    }
  },
  mounted() {
    this.search = this.searchTerm || ''
  },
  methods: {
    handleSearch(event) {
      if (event.key === 'Enter' || event.key === 'ArrowDown') {
        event.target.blur()
      }
      this.setSearch(this)
    },
    setSearch: debounce((ctx) => {
      const filters = {
        query: ctx.search || ''
      }
      ctx.$emit('setSearch', filters)
    }, 700)
  }
}
</script>

<style lang="scss">
.search-form {
  &.v-text-field--outlined:not(.v-input--is-focused):not(.v-input--has-state) > .v-input__control > .v-input__slot fieldset {
    border-color: $color-primary !important;
  }
  .v-icon {
    color: $color-primary !important;
  }
  input {
    &:placeholder-shown {
      font-family: Lato;
      font-style: normal;
      font-weight: normal;
      font-size: 16px;
      line-height: 19px;
      color: $color-grey;
    }
  }
}
</style>
