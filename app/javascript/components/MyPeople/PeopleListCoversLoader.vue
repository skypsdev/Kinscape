<template>
  <div class="loader-wrapper">
    <content-loader
      viewBox="0 0 400 160"
      height="160"
      width="400"
      primary-color="#f3f3f3"
      secondary-color="#ecebeb"
    >
      <circle cx="150" cy="86" r="8" />
      <circle cx="194" cy="86" r="8" />
      <circle cx="238" cy="86" r="8" />
    </content-loader>
  </div>
</template>

<script>
import { ContentLoader } from 'vue-content-loader'

export default {
  name: "PeopleListCoversLoader",
  components: { ContentLoader }
}
</script>
<style scoped>
.loader-wrapper {
  height: 200px;
  display: flex;
  justify-content: center;
}
</style>