<template>
  <v-dialog
    :scrollable="dialog.scrollable"
    v-model="showDialog"
    :max-width="sizeDialog"
  >
    <v-fade-transition mode="out-in">
      <component
        v-if="dialog.component"
        :is="dialogContent()"
      />
    </v-fade-transition>
  </v-dialog>
</template>

<script>
import {mapActions, mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      dialog: state => state.layout.dialog
    }),
    showDialog: {
      get: function () {
        return this.dialog.active
      },
      set: function (newValue) {
        if (!newValue) this.closeDialog()
      }
    },
    sizeDialog() {
      const size = {
        small: '375px',
        default: '780px',
        big: '1099px'
      }
      return size[this.dialog.size] || size.default
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog'
    }),
    dialogContent() {
      const componentName = this.dialog.component || {};
      if (componentName && !this.$options.components[componentName]) {
        this.$options.components[componentName] = () => import(`../../../components/Dialogs/${componentName}.vue`);
      }
      return componentName;
    }
  }
}
</script>