<template>
  <div class="mt-10" infinite-wrapper>
    <v-row class="list__header mb-4 pa-0">
      <v-col cols="3" class="list__header-col pa-0 pl-4 d-flex align-center">
        {{ $i18n.t('communities.list_view.title') }}
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        {{ $i18n.t('communities.list_view.type') }}
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        <span>
          {{ $i18n.t('communities.list_view.date_created') }}
        </span>
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        <span>
          {{ $i18n.t('communities.list_view.members') }}
        </span>
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        <span>{{ $i18n.t('communities.list_view.admin') }}</span>
      </v-col>
    </v-row>
    <CommunityRow
        v-for="community in communities"
        :key="community.id"
        :community="community"
    />
  </div>
</template>
<script>
import { mapState } from "vuex";
import CommunityRow from "@/components/Communities/CommunityRow";

export default {
  components: { CommunityRow },
  computed: {
    ...mapState({
      communities: store => store.families.all
    }),
  }
}
</script>
<style lang="scss" scoped>
.list {
  &__header {
    background: $color-light-grey;
    border-radius: 5px;
    height: 40px;
  }
  &__header-col {
    max-height: 40px;
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 16px;
    line-height: 21px;
    color: $color-tertiary;
  }
}
</style>
