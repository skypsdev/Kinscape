<template>
  <v-dialog
    :content-class="dialogConfiguration.customClass"
    :persistent="persistent"
    :scrollable="scrollable"
    v-model="showDialog"
    :max-width="sizeDialog"
    :overlay-opacity="0.7"
  >
    <template v-slot:activator="{ on, attrs }">
      <slot name="activator" :on="on" :attrs="attrs" />
    </template>

    <slot>
      <v-fade-transition mode="out-in">
        <component v-if="dialogConfiguration.component" :is="dialogContent()" />
      </v-fade-transition>
    </slot>
  </v-dialog>
</template>

<script>
import { mapActions, mapState } from 'vuex'

export default {
  props: {
    configuration: {
      type: Object,
      default: () => null
    }
  },
  computed: {
    ...mapState({
      dialog: state => state.layout.dialog
    }),
    dialogConfiguration() {
      return this.configuration || this.dialog
    },
    scrollable() {
      return this.dialogConfiguration?.scrollable ?? false
    },
    persistent() {
      return this.dialogConfiguration?.persistent ?? false
    },
    showDialog: {
      get: function () {
        return this.dialogConfiguration?.active
      },
      set: function (newValue) {
        if (!newValue) {
          this.closeDialog()
        }
        this.$emit('update:active', newValue)
      }
    },
    sizeDialog() {
      const size = {
        small: '375px',
        default: '780px',
        big: '1099px'
      }

      return this.dialogConfiguration?.customSize || size[this.dialogConfiguration?.size] || size.default
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog'
    }),
    dialogContent() {
      const componentName = this.dialog?.component;

      if (componentName && !this.$options.components[componentName]) {
        this.$options.components[componentName] = () => import(`@/components/Dialogs/${componentName}.vue`)
      }

      return componentName
    }
  }
}
</script>
