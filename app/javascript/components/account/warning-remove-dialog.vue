<template>
  <div
    v-if="showWarning"
    class="modal confirmation-dialog warning-account active"
  >
    <div class="overlay" />
    <div class="vertical-center">
      <div class="vc-cell">
        <div class="modal-container">
          <div class="modal-content">
            <div class="modal-inner-wrapper">
              <h2 class="form-title">
                Last Warning!
              </h2>
              <p class="form-message">
                Permanently remove my account, {{ currentUser.name }}, and any
                content that I have contributed?
              </p>
              <p class="form-message">
                I understand that all my content will be deleted and this
                CANNOT BE UNDONE!
              </p>
              <!-- <p class="form-message">
                <a
                  class="i fa fa-cloud-download"
                  data-method="post"
                  href="/downloads"
                >
                  Download My Content
                </a>
              </p> -->
              <div class="controls-block">
                <button
                  class="control ok"
                  name="commit"
                  type="button"
                  @click="deleteAccount"
                >
                  Permanently Delete My Account
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
    showWarning: Boolean
  },
  methods: {
    deleteAccount () {
      this.$emit('hide-warning-modal', true)

      this.$http.delete('/users').then(() => {
        location.href = '/account'
      }, () => {
        this.$emit('failure')
      })
    },
    closeModal () {
      this.$emit('hide-warning-modal', true)
    }
  }
}
</script>
