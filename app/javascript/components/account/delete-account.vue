<template>
  <div id="delete-account">
    <a
      class="remove-account close_account"
      @click="showConfirmModal"
    >
      <i
        aria-hidden="true"
        class="fa fa-minus-circle"
      />
      &nbsp;Delete Account
    </a>
    <confirmation-remove-account-modal
      :show-confirm="showConfirm"
      :current-user="currentUser"
      @show-warning-modal="showWarningModal"
      @hide-confirm-modal="hideConfirmModal"
    />
    <warning-remove-account-modal
      :current-user="currentUser"
      :show-warning="showWarning"
      @hide-warning-modal="hideWarningModal"
    />
  </div>
</template>

<script>
import ConfirmationRemoveAccountModal from './confirmation-remove-dialog'
import WarningRemoveAccountModal from './warning-remove-dialog'

export default {
  components: { ConfirmationRemoveAccountModal, WarningRemoveAccountModal },
  props: {
    currentUser: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      showConfirm: false,
      showWarning: false
    }
  },
  methods: {
    showConfirmModal () {
      this.showConfirm = true
    },
    hideConfirmModal () {
      this.showConfirm = false
    },
    showWarningModal () {
      this.showConfirm = false
      this.showWarning = true
    },
    hideWarningModal () {
      this.showWarning = false
    }
  }
}
</script>

<style lang="scss">
  .remove-account {
    cursor:pointer;
    &:hover {
      color: rgb(0,0,0);
      .fa-minus-circle {
        color: rgb(0,0,0);
      }
    }
  }
  .modal.confirmation-dialog.warning-account .controls-block {
    button.ok {
      background: red;
      border: red;
    }
  }
  .txt_center {
    text-align: center;
    font-size: 15px !important;
  }
  .s23{
    font-size: 23px !important;
  }
</style>
