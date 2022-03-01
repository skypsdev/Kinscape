<template>
  <div
    v-if="showConfirm"
    class="modal confirmation-dialog remove-family active"
  >
    <div class="overlay" />
    <div class="vertical-center">
      <div class="vc-cell">
        <div class="modal-container">
          <div class="modal-content">
            <div class="modal-inner-wrapper">
              <h2 class="form-title">
                Are you sure?
              </h2>
              <p class="form-message">
                You are about to remove yourself from {{ familyName }}.
                Doing so is permanent. Any content you've previously
                contributed to this group will be deleted and cannot be
                recovered.
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
                  Ok
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
    family: {
      type: Object,
      required: true
    },
    showConfirm: Boolean
  },
  computed: {
    familyName () {
      return this.family && this.family.attributes.name
    }
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
