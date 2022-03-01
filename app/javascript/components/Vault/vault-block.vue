<template>
  <li class="vault block">
    <router-link
      :to="{ name: 'showVault', params: { id: vault.id } }"
      class="cover"
    >
      <div
        class="cover-bg"
        :style="backgroundImage(vault.attributes.cover_url)"
      />
      <div class="title">
        <div class="alignment-guide" />
        <div class="title-wrapper">
          <!-- eslint-disable vue/no-v-html -->
          <h2>
            {{ vault.attributes.name }}
          </h2>
        </div>
      </div>
    </router-link>
  </li>
</template>

<script>
import { mapActions, mapState } from 'vuex'
export default {
  props: {
    vault: {
      type: Object,
      required: true
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    })
  },
  methods: {
    ...mapActions([
      'successFlashMessage'
    ])
  }
}
</script>
