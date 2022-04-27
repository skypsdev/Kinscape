<template>
  <v-container class="toolbar" fluid>
    <v-row class="d-flex justify-space-between">
      <v-col>
        <v-spacer />
      </v-col>
      <v-col>
        <MyLifeMenu />
      </v-col>
      <v-col class="d-flex justify-end">
        <v-btn
          class="ml-2"
          v-if="editing && isCurrentUserAllowedToEdit"
          color="primary"
          elevation="0"
          title="Cancel"
          rounded
          outlined
          @click="handleCancel"
        >
          {{ $i18n.t('communities.edit.save') }}
        </v-btn>

        <v-btn
          class="ml-2"
          v-if="!editing && isCurrentUserAllowedToEdit"
          :fab="isMobile"
          :small="isMobile"
          rounded
          outlined
          color="primary"
          elevation="0"
          :title="$i18n.t('families.edit_title')"
          @click="handleEdit"
        >
          <v-icon :left="!isMobile">mdi-pencil</v-icon>
          <span v-if="!isMobile">
            {{ $i18n.t('families.edit') }}
          </span>
        </v-btn>

        <Menu
          v-model="toggleOptions"
          class="ml-2"
          v-if="!editing"
          theme="toolbar"
          :items="menuOptions"
          :elevation="1"
          @downloadProfile="downloadProfile"
        >
          <template v-slot:activator="{ on, attrs }">
            <v-btn
              class="ml-2"
              color="primary"
              fab
              outlined
              :x-small="!isMobile"
              :small="isMobile"
              elevation="0"
              v-bind="attrs"
              v-on="on"
            >
              <v-icon>mdi-dots-horizontal</v-icon>
            </v-btn>
          </template>
        </Menu>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import breakpointsMixin from '../../mixins/breakpointsMixin'
import MyLifeMenu from './MyLife/MyLifeMenu'
import Menu from '../../components/Menu/Menu'

export default {
  components: {
    MyLifeMenu,
    Menu
  },
  mixins: [breakpointsMixin],
  data: () => ({
    menuOptions: [
      {
        id: 'downloadProfile',
        title: 'Download Profile',
        action: 'downloadProfile'
      }
    ],
    toggleOptions: false
  }),
  computed: {
    ...mapState({
      isLoading: (state) => state.kinships.loading,
      kinships: (state) => state.kinships,
      currentUser: (state) => state.core.user,
      chosenFamilyId: (state) => state.families.simpleList.families[0]?.id,
      member: (store) => store.members.member
    }),
    isCurrentUserAllowedToEdit() {
      return this.$possible('manage', 'Kinship', {
        userId: this.member.userId, familyId: this.member.familyId, accessType: this.member.accessType
      })
    },
    editing() {
      return this.$route.query.editing === 'true'
    }
  },
  mounted() {
    if (!this.member?.userId) {
      this.getMyProfileByCommunityId({id:this.chosenFamilyId, params:this.getShowcaseOptions()})
    }
  },
  methods: {
    ...mapActions({
      getMyProfileByCommunityId: 'members/getMyProfileByCommunityId',
      setChangeStatus: 'members/setChangeStatus'
    }),
    downloadProfile() {
      console.info('Downloading profile...')
  },
  getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
        result.showcase = true
      }

      return result
    },
    handleEdit() {
      this.$router.push({ query: { ...this.$route.query, editing: true } })
    },
    handleCancel() {
      this.setChangeStatus(false)
      this.$router.replace({ query: {community: this.$route.query.community } })
      this.$router.go()
    }
  }
}
</script>

<style lang="scss">
.toolbar {
  background-color: $color-dark-white;
}
</style>
