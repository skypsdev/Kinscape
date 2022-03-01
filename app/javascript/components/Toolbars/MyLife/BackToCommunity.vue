<template>
  <v-btn
    class="ml-1"
    rounded
    text
    :to="`/communities/${chosenFamilyId}`"
  >
    <v-icon left>
      mdi-arrow-left
    </v-icon>
    {{ $i18n.t('users.kinships.profile.back_link') }}
  </v-btn>
</template>

<script>
import {mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      // TODO-SELECTED-FAMILY-ID: use correct family id
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    })
  }
}
</script>
