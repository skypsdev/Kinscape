<template>
  <v-text-field
    v-if="$vuetify.breakpoint.md"
    flat
    v-model="search"
    class="search-input"
    :class="
      theme === 'primary' ? 'search-form-primary' : 'search-form-secondary'
    "
    rounded
    dense
    outlined
    hide-details
    single-line
    :color="theme === 'primary' ? 'primary' : 'secondary'"
    clearable
    :label="placeholder"
    type="text"
    prepend-inner-icon="mdi-magnify"
    @keydown="handleSearch"
    @click:clear="handleSearch"
  />
  <v-menu
    v-else
    v-model="showMenu"
    content-class="search-input__popup"
    bottom
    :close-on-content-click="false"
  >
    <template #activator="{ on, attrs }">
      <v-btn
        v-bind="attrs"
        class="d-sm-none mx-1"
        rounded
        color="primary"
        elevation="0"
        fab
        small
        outlined
        v-on="on"
      >
        <v-icon size="18">mdi-magnify</v-icon>
      </v-btn>
    </template>

    <v-card class="search-input__box">
      <v-card-text>
        <v-text-field 
          v-model="search"
          class="searc-input"
          :color="theme === 'primary' ? 'primary' : 'secondary'"
          :label="placeholder"
          type="text"
          prepend-inner-icon="mdi-magnify"
          hide-details
          clearable
          outlined
          rounded
          dense
          flat
          @keydown="handleSearch"
          @click:clear="handleSearch"
          @keydown.enter="showMenu = false"
        />
      </v-card-text>
    </v-card>
  </v-menu>
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
      default: function () { return this.$i18n.t('placeholders.search') }
    },
    theme: {
      type: String,
      default: 'primary'
    }
  },
  data: () => ({
    search: '',
    showMenu: false
  }),
  watch: {
    searchTerm(query) {
      this.search = query
    }
  },
  created() {
    this.search = this.searchTerm ?? ''
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
        query: ctx.search ?? ''
      }
      ctx.$emit('setSearch', filters)
    }, 700)
  }
}
</script>

<style lang="scss">
.search-form-primary {
  &.v-text-field--outlined:not(.v-input--is-focused):not(.v-input--has-state)
    > .v-input__control
    > .v-input__slot
    fieldset {
    border-color: $color-primary !important;
  }
  .v-icon {
    color: $color-primary !important;
  }
}
.search-form-secondary {
  &.v-text-field--outlined:not(.v-input--is-focused):not(.v-input--has-state)
    > .v-input__control
    > .v-input__slot
    fieldset {
    border-color: $color-secondary !important;
  }
  .v-icon {
    color: $color-secondary !important;
  }
}

.search-input {
  &:placeholder-shown {
    font-family: Lato;
    font-style: normal;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;
    color: $color-grey;
  }

  &__popup {
    border-radius: 32px;
  }
}
</style>
