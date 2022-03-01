<template>
  <div>
    <nav class="my-life-submenu mt-10">
      <div class="story-tabs family-tabs">
        <a
          class="tab"
          :class="{'active':!routeCheck}"
          href="/account"
        >
          Account Info
        </a>
        <a
          class="tab"
          :class="{'active':routeCheck}"
          href="/communityInfo"
        >
          Community Info
        </a>
      </div>
    </nav>
  </div>
</template>

<script>
export default {
  data () {
    return {
      routeCheck: false
    }
  },
  created () {
    if (this.$router) {
      this.routeCheck = true
    }
  }
}
</script>

<style scoped>
.mt-10 {
  margin-top: 10px;
}
</style>
