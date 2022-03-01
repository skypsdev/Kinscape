<template>
  <div
    v-if="showWarning"
    class="modal confirmation-dialog warning-family active"
  >
    <div class="overlay" />
    <div class="vertical-center">
      <div class="vc-cell">
        <div class="modal-container">
          <div class="modal-content">
            <div class="modal-inner-wrapper">
              <h2 class="form-title">
                Warning!
              </h2>
              <p class="form-message">
                Permanently remove {{ currentUser.name }} and any
                content I have contributed to
                {{ family && family.attributes.name }}?
              </p>
              <p class="form-message">
                I understand that my content will be deleted and this
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
                  @click="removeFamily"
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
    currentUser: {
      type: Object,
      required: true
    },
    showWarning: Boolean
  },
  methods: {
    removeFamily () {
      this.$emit('hide-warning-modal', true)

      this.$http.delete('/api/v1/kinships/' + this.family.id).then(() => {
        this.$emit('removed-family', this.family)
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
