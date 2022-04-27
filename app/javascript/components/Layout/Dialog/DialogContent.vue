<template>
  <v-card
    v-bind="$attrs"
    class="dialog"
    flat
  >
    <header v-if="!dialog.isToolbarHidden && header" class="dialog-header">
      <h2 class="dialog-title">{{ dialogTitle }}</h2>
      <slot v-if="!dialog.hideCloseBtn" name="close-btn" :handle-close="handleClose">
        <v-btn icon @click="handleClose">
          <v-icon big>mdi-close</v-icon>
        </v-btn>
      </slot>
    </header>

    <v-card-text
        v-if="$slots.content"
        class="dialog-content"
        :style="{
          'background-color': backgroundColor,
          'margin-bottom': marginBottom,
        }"
    >
      <slot name="content" />
    </v-card-text>

    <v-card-actions
      v-if="$slots.actions"
      class="dialog__footer"
      :class="justifyCenter && 'justify-center'"
    >
      <slot name="actions" />
    </v-card-actions>
  </v-card>
</template>

<script>
import { mapState, mapActions } from 'vuex'
export default {
  props: {
    justifyCenter: {
      type: Boolean,
      default: true,
    },
    closeGlobalDialog: {
      type: Boolean, default: true
    },
    title: { type: String, required: false },
    header: { type: Boolean, default: true },
    backgroundColor: {
      type: String,
      required: false,
      default: "#ffffff"
    },
    marginBottom: {
      type: String,
      required: false,
      default: "0"
    },
  },
  computed: {
    ...mapState({
      dialog: (state) => state.layout.dialog
    }),
    dialogTitle() {
      return this.title ?? this.dialog.title
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog'
    }),
    handleClose() {
      if (this.closeGlobalDialog) {
        this.closeDialog()
      }

      this.$emit('close')
    }
  }
}
</script>

<style lang="scss">
.dialog {
  &-header {
    align-items: center;
    border-bottom: 1px solid #c4c4c4;
    display: flex;
    justify-content: space-between;
    padding: 20px 20px 11px 20px;
  }

  &-title {
    font-size: 30px;
  }

  &-content {
    .dialog-content__title {
      color: #4b4b4b;
      font-weight: 600;
      font-size: 20px;
      line-height: 27px;
      margin-bottom: 8px;
    }
    .dialog-content__text {
      color: #666;
      font-size: 16px;
      line-height: 25px;

      a {
        text-decoration: none;
      }
    }
  }

  .theme--light.v-btn.v-btn--disabled {
    background: #e6e6e6;
    border-color: #e6e6e6;
    color: #9b9b9b !important;
  }

  .v-card__actions {
    .v-btn {
      margin-right: 15px;

      &:last-child {
        margin-right: 0;
      }
    }
  }
}
</style>
