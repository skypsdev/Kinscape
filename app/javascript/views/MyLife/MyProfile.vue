<template>
  <div class="legacy-styles">
    <div
      v-if="!isLoading"
      class="user-profile align-center d-flex pt-60 pb-30"
    >
      <div
        v-if="kinship"
        class="profile-wrapper flex-wrap justify-center no-profile-information"
      >
        <ProfileDetails
          :user="user"
          :kinship="kinship"
          :edit-mode="true"
        />
        <TableOfChapter
          :toc-links="kinship.attributes.links"
          :chapters="kinships.chapters"
          :is-edit-mode="true"
          :family-id="chosenFamilyId"
          :type-object="'Kinship'"
          :kinship-id="kinship.id"
        />
        <TableOfContents
          :current-user="currentUser"
          :kinship="kinship"
          :chapters="kinships.chapters"
        />
      </div>
      <ProfileWithoutCommunity v-if="!kinship" />
    </div>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import TableOfChapter from '../../components/shared/table-of-chapter.vue'
import TableOfContents from '../../components/shared/TableOfContents'
import ProfileDetails from '../../components/users/profile-details'
import ProfileWithoutCommunity from '../../components/Profiles/ProfileWithoutCommunity'

export default {
  components: {
    ProfileWithoutCommunity,
    ProfileDetails,
    TableOfChapter,
    TableOfContents
  },
  computed: {
    ...mapState({
      isLoading: state => state.kinships.loading,
      kinships: state => state.kinships,
      currentUser: state => state.core.user,
      // TODO-SELECTED-FAMILY-ID: use correct family id
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    }),
    kinship () {
      return this.kinships.all.find(a => a.id === this.kinships.kinshipId)
    },
    user () {
      return this.kinship
        ? this.kinship.included.find(k => k.type === 'user')
        : undefined
    }
  },
  watch: {
    'chosenFamilyId': 'getMyProfile'
  },
  mounted() {
    this.getMyProfile()
  },
  methods: {
    ...mapActions({
      getKinshipByFamily: 'kinships/getKinshipByFamily',
      setSubHeader: 'layout/setSubHeader',
      closeSubHeader: 'layout/closeSubHeader'
    }),
    getMyProfile () {
      this.getKinshipByFamily(this.chosenFamilyId)
    }
  }
}
</script>

<style lang="scss" scoped>
  @import "../../assets/styles/views/myLife";
</style>
