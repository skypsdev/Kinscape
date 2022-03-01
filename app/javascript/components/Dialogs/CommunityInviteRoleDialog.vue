<template>
  <DialogContent>
    <template v-slot:content>
      <h2 class="invitation__heading mt-10">
        {{ $i18n.t('communities.inviteDialog.roleHeading') }}
      </h2>
      <p class="invitation__description">
        {{ $i18n.t('communities.inviteDialog.roleDescription', { communityType: community.type }) }}
      </p>
      <v-divider/>
      <h2 class="invitation__heading mt-6">
        {{ $i18n.t('communities.inviteDialog.roleSubheading') }}
      </h2>
      <v-col cols="12" md="5">
        <Search :search-term="searchTerm" @setSearch="setSearch"/>
      </v-col>
      <div class="select-area px-3 px-md-6 mt-5">
        <v-row v-for="user in payload.users" :key="user.id" class="pa-3">
          <v-col cols="4" md="1" class="pa-0">
            <Avatar size="medium"/>
          </v-col>
          <v-col cols="8" md="7" class="d-flex align-center pa-0 pl-md-3">
            <p class="select-area__name mb-0">{{ user.name || user.email }}</p>
          </v-col>
          <v-col offset="2" cols="8" offset-md="0" md="4" class="d-flex align-center pa-0">
            <v-select
                rounded
                dense
                outlined
                hide-details
                color="primary"
                :items="roles"
                v-model="user.role"
            />
          </v-col>
        </v-row>
      </div>
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
            x-large
            rounded
            outlined
            color="primary"
            elevation="0"
            class="ma-1"
            min-width="160px"
            min-height="48px"
            @click="goBack"
        >
          {{ $i18n.t('communities.inviteDialog.back') }}
        </v-btn>
        <v-btn
            x-large
            rounded
            color="primary"
            elevation="0"
            class="ma-1"
            min-width="160px"
            min-height="48px"
            @click="nextStep"
        >
          {{ $i18n.t('communities.inviteDialog.next') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapActions, mapState } from 'vuex'
import Search from "../Elements/Forms/Search";
import Avatar from "../Elements/Avatar";

export default {
  components: {
    Avatar,
    DialogContent,
    Search
  },
  data() {
    return {
      payload: {},
      roles: [
        'Co-admin',
        'Member',
        'Guest'
      ],
      searchTerm: '',
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community,
      dialog: state => state.layout.dialog
    }),
  },
  watch: {
    'payload.users' () {
      this.search = ''
    },
  },
  created() {
    this.payload = this.dialog.data.payload
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setDialog: 'layout/setDialog',
      setSnackbar: 'layout/setSnackbar',
      setError: 'layout/setError',
    }),
    async nextStep () {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'CommunityInviteMessageDialog',
        size: 'big',
        data: { payload: this.payload },
      })
    },
    goBack () {
      this.setDialog({
        title: this.$i18n.t('communities.inviteDialog.title', { communityType: this.community.type }),
        component: 'CommunityInviteDialog',
        size: 'big',
        data: { payload: this.payload },
      })
    },
    setSearch(search) {
      this.searchTerm = search.query
    },
  }
}
</script>
<style lang="scss" scoped>
.invitation {
  &__heading {
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    color: $color-tertiary;
  }
  &__description {
    font-size: 16px;
    line-height: 19px;
    color: $color-text;
  }
}
.select-area {
  min-height: 162px;
  background-color: #F7F7F7;
  border-radius: 5px;
  &__name {
    font-style: normal;
    font-weight: 600;
    font-size: 17px;
    line-height: 24px;
    color: $color-tertiary;
  }
}
</style>
