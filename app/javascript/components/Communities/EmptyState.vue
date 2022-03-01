<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
        class="mb-12"
        height="320"
        contain
        :src="require('../../assets/images/empty-state-icon.svg')"
    />
    <h4 class="empty-state__heading f--tertiary text-center mx-auto mb-5">{{ $i18n.t('communities.empty_state.heading') }}</h4>
    <p class="empty-state__p f--tertiary text-center mx-auto mb-5">
      {{ $i18n.t('communities.empty_state.description') }}
    </p>
    <AddCommunityButton class="mx-auto"/>
  </v-container>
</template>
<script>
import { mapState } from "vuex";
import AddCommunityButton from "../Toolbars/Communities/AddCommunityButton";

export default {
  components: {AddCommunityButton},
  computed: {
    ...mapState({
      searchTerm: state => state.families.filters.search,
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
    font-family: Enriqueta;
    font-size: 22px;
    line-height: 34px;
  }
}
</style>
