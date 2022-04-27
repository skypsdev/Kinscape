<template>
  <div>
    <div class="d-flex align-center mb-2">
      <v-icon v-if="icon" class="mr-3" color="tertiary">
        {{ icon }}
      </v-icon>
      <h4
        v-if="label"
        class="subtitle-1 f--tertiary font-weight-bold d-inline-block mr-3"
      >
        {{ label }}
      </h4>
      <Menu
        v-if="showOptions"
        v-model="showMenu"
        theme="toolbar"
        :elevation="1"
        :items="defaultMenuOptions"
        @changeLabel="changeLabel"
      >
        <template #activator="{ on, attrs }">
          <v-btn
            v-bind="attrs"
            v-on="on"
            class="primary--text"
            elevation="0"
            small
          >
            {{ buttonLabel }}

            <v-icon small>
              mdi-menu-down
            </v-icon>
          </v-btn>
        </template>
      </Menu>
    </div>
    <div>
      <slot />
    </div>
  </div>
</template>

<script>
import Menu from '@/components/Menu/Menu'

export default {
  components: {
    Menu
  },
  props: {
    value: {
      type: String,
      default: ''
    },
    icon: {
      type: String,
      default: ''
    },
    label: {
      type: String,
      default: ''
    },
    options: {
      type: Array,
      default: () => []
    }
  },
  data: () => ({
    showMenu: false
  }),
  computed: {
    defaultMenuOptions () {
      return this.options
        ?.map((option) => ({
          ...option,
          action: 'changeLabel'
        })) || []
    },
    showOptions () {
      return !!this.options?.length
    },
    buttonLabel () {
      return this.options
        .find(({ value }) => value === this.value)
        ?.title || ''
    }
  },
  methods: {
    changeLabel (e) {
      this.showMenu = false
      this.$emit('input', e.value)
    }
  }
}
</script>
