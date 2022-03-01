<template>
  <v-select
    class="select-community"
    rounded
    dense
    outlined
    hide-details
    color="primary"
    item-text="attributes.name"
    item-value="id"
    :items="families"
    :disabled="isLoading"
    prepend-inner-icon="mdi-text-box-outline"
    v-model="selectedCommunity"
  />
</template>

<script>
import {mapActions, mapGetters, mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      families: state => state.families.simpleList.families,
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    }),
    ...mapGetters({
      isLoading: 'stories/isLoading'
    }),
    selectedCommunity: {
      get: function () {
        // TODO-SELECTED-FAMILY-ID: use correct family id
        return this.chosenFamilyId
      },
      set: function () {
        this.forFamilyType('')
      }
    },
  },
  methods: {
    ...mapActions({
      forFamilyType: 'stories/forFamilyType'
    })
  }
}
</script>

<style lang="scss" scoped>
  .select-community {
    max-width: 200px;
  }
</style>
