<template>
  <div
    v-if="showConfirm"
    class="modal confirmation-dialog remove-account active"
  >
    <div class="overlay" />
    <div class="vertical-center">
      <div class="vc-cell">
        <div class="modal-container">
          <div class="modal-content">
            <div class="modal-inner-wrapper">
              <h2 class="form-title">
                Delete Account?
              </h2>
              <p class="form-message txt_center">
                <span class="s23">Warning!</span><br>
                You are about to <b><u style="color: black;">Delete Account for
                  {{ currentUser.email }}</u></b>.
                All Content (including Images, Files,
                Stories, and Profiles) you have added
                to Kinscape <u>using this account
                  login</u> will be deleted forever and
                cannot be recovered.
                This action will terminate access
                to  Kinscape <u>using this email address</u>.
              </p>
              <!--<p class="form-message">
                <a
                  class="i fa fa-cloud-download"
                  data-method="post"
                  href="/downloads"
                >
                  Download My Content
                </a>
              </p>-->
              <div class="controls-block">
                <button
                  class="control ok"
                  name="commit"
                  type="button"
                  @click="showWarningModal"
                >
                  CONFIRM ACCOUNT DELETION
                </button>
                <button
                  class="control btn-default cancel"
                  type="button"
                  @click="closeModal"
                >
                  Cancel
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    currentUser: {
      type: Object,
      required: true
    },
    showConfirm: Boolean
  },
  methods: {
    showWarningModal () {
      this.$emit('show-warning-modal', true)
    },
    closeModal () {
      this.$emit('hide-confirm-modal', true)
    }
  }
}
</script>
