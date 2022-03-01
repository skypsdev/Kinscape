<template>
  <div class="alert-container">
    <transition name="fade">
      <div
        v-if="flashMessage.message"
        id=""
        role="alert"
        class="alert alert-dismissible"
        :class="{
          'alert-success': flashMessage.type === 'success',
          'alert-danger': flashMessage.type === 'failure'
        }"
      >
        <div
          type="button"
          class="close"
          aria-hidden="false"
        >
          <span
            aria-hidden="true"
            @click="clearMessage"
          >×</span>
          <span
            class="sr-only"
            @click="clearMessage"
          >Close</span>
        </div>
        <span dynamic="flash.text">{{ flashMessage.message }}</span>
      </div>
    </transition>
  </div>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

export default {
  computed: {
    ...mapGetters([
      'flashMessage'
    ])
  },
  created () {
    this.$store.watch(
      (state, getters) => getters.flashMessage.message,
      (newValue) => {
        if (newValue) setTimeout(this.clearMessage, 5000)
      }
    )
  },
  methods: {
    ...mapActions([
      'successFlashMessage',
      'failureFlashMessage'
    ]),
    clearMessage () {
      if (window.environment !== 'test') {
        this.successFlashMessage(null)
        this.failureFlashMessage(null)
      }
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
</style>
