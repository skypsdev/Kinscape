<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
        class="mb-12"
        height="320"
        contain
        :src="require('../../assets/images/no_chapters.svg')"
    />
    <p class="empty-state__p f--tertiary text-center mx-auto">
      {{ $i18n.t('communities.chapter_empty_state.label') }}
    </p>
    <AddChapter
        class="mx-auto"
        :position="community.content.links.length"
        view-type="community"
        :edit-mode="editMode"
    />
  </v-container>
</template>
<script>
import { mapState } from "vuex";
import AddChapter from "../Elements/Chapters/AddChapter";

export default {
  components: { AddChapter },
  props: {
    editMode: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community
    }),
  }
}
</script>
<style lang="scss" scoped>
.empty-state {
  &__p {
    max-width: 450px;
    font-family: Lato;
    font-style: normal;
    font-size: 17px;
    line-height: 24px;
    text-align: center;
    color: #4B4B4B;
  }
}
</style>
