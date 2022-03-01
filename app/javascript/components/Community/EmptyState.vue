<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
        class="mb-12"
        height="320"
        contain
        :src="require('../../assets/images/no_chapters.svg')"
    />
    <p class="empty-state__p f--tertiary text-center mx-auto mb-0 pb-0">
      {{ $i18n.t('communities.chapter_empty_state.label') }}
    </p>
    <p class="empty-state__p f--tertiary text-center mx-auto mt-0 pt-0 mb-5">
      {{ $i18n.t('communities.chapter_empty_state.call_to_action') }}
    </p>
    <AddChapter
        class="mx-auto"
        :position="community.content.links.length"
        view-type="community"
    />
  </v-container>
</template>
<script>
import { mapState } from "vuex";
import AddChapter from "../Elements/Chapters/AddChapter";

export default {
  components: { AddChapter },
  computed: {
    ...mapState({
      community: state => state.families.community
    }),
  }
}
</script>
<style lang="scss" scoped>
.empty-state {
  &__heading {
    font-weight: bold;
    font-size: 32px;
    line-height: 43px;
  }
  &__p {
    max-width: 692px;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 17px;
    line-height: 24px;
    text-align: center;
    color: #4B4B4B;
  }
}
</style>
