<template>
  <MountingPortal
    mount-to="#vue-modal"
    append
  >
    <modal
      :name="dialogName"
      :adaptive="true"
      :width="1200"
      height="auto"
    >
      <transition name="fade">
        <div class="confirmation-dialog modal-inner-wrapper">
          <h2 class="form-title">
            {{ dialogTitle }}
          </h2>
          <!-- eslint-disable vue/no-v-html -->
          <p
            class="form-message"
            v-html="dialogMessage"
          />
          <!-- eslint-enable -->
          <div class="controls-block">
            <button
              class="control ok"
              type="button"
              @click="$emit('confirmation-ok')"
            >
              {{ confirmButton }}
            </button>
            <button
              class="control btn-default cancel"
              type="button"
              @click="$emit('confirmation-cancel')"
            >
              {{ cancelButton }}
            </button>
          </div>
        </div>
      </transition>
    </modal>
  </MountingPortal>
</template>

<script>
export default {
  props: {
    dialogName: {
      type: String,
      default: 'confirmation-modal'
    },
    dialogTitle: {
      type: String,
      default: 'Are you Sure?'
    },
    dialogMessage: {
      type: String,
      required: true
    },
    confirmButton: {
      type: String,
      default: 'OK'
    },
    cancelButton: {
      type: String,
      default: 'Cancel'
    }
  }
}
</script>

<style lang="scss" scoped>
  .fade-enter-active, .fade-leave-active {
    transition: opacity .5s;
  }

  .fade-enter, .fade-leave-to {
    opacity: 0;
  }

  .modal-inner-wrapper {
    width: calc(100% - 40px);
    float: left;
    margin-left: 20px;
    padding: 3em;
  }

  .form-message strong {
    font-weight: 600;
  }

  .controls-block {
    .control {
      width: calc(50% - 30px);
      float: left;
      margin-left: 20px;
    }

    &.single-button {
      .control {
        float: none;
        margin: 0 auto;
      }
    }
  }
</style>
