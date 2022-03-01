<template>
  <div class="mt-10" infinite-wrapper>
    <v-row class="list__header mb-4 pa-0">
      <v-col cols="3" class="list__header-col pa-0 pl-4 d-flex align-center">
        {{ $i18n.t('communities.members.list_view.name') }}
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        {{ $i18n.t('communities.members.list_view.role') }}
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        <span v-if="isInvitation">
          {{ $i18n.t('communities.members.list_view.date_invited') }}
        </span>
        <span v-else>
          {{ $i18n.t('communities.members.list_view.date_joined') }}
        </span>
      </v-col>
      <v-col class="list__header-col d-flex align-center">
        <span>{{ $i18n.t('communities.members.list_view.invited_by') }}</span>
      </v-col>
      <v-col cols="3" class="list__header-col d-flex align-center">
        {{ $i18n.t('communities.members.list_view.actions') }}
      </v-col>
    </v-row>
    <MemberRow
        v-for="member in finalMemberList"
        :key="member.id"
        :member="member"
        :is-invitation="isInvitation"
    />
  </div>
</template>
<script>
import MemberRow from "./MemberRow";

export default {
  components: { MemberRow },
  props: {
    isInvitation: {
      type: Boolean,
      default: false
    },
    finalMemberList: {
      type: Array,
      default: () => []
    },
    reqType: {
      type: String,
      default: "defaults"
    }
  },
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
