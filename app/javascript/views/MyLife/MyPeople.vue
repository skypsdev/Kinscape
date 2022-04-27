<template>
  <v-container class="people-container">
    <portal class="d-flex pl-14" to="my-people-header">
      <SelectViewType :view-type="viewType" @setViewType="viewType = $event" />
    </portal>

    <v-row class="mt-12">
      <v-col class="d-flex flex-row align-center py-0">
        <h1 class="grid__title f--tertiary">My People</h1>

        <div class="d-flex align-center people-header" v-if="!noData">
          <h3 class="people-header__subtitle f--grey ml-5">Total</h3>
          <span class="people-header__dot"></span>
          <h3 class="people-header__subtitle f--grey">{{ totalFollow }}</h3>
        </div>
      </v-col>
    </v-row>

    <v-row class="mt-6 mb-8 flex-column flex-md-row">
      <v-col class="col-auto pr-0" v-if="!noData">
        <VSearch
          class="people-search"
          :search-term="search"
          @setSearch="filterResults"
        />
      </v-col>
      <v-col class="col-lg-3 pl-2">
        <!-- show Invite Modal btn -->
        <v-btn
          rounded
          outlined
          color="#8B78FE"
          elevation="0"
          @click="showInviteModal"
        >
          <v-icon class="pr-2">mdi-plus-circle-outline</v-icon>
          <span>{{ $i18n.t("mylives.my_people.invite") }} </span>
        </v-btn>
      </v-col>
    </v-row>

    <PeopleListCoversLoader v-if="loading || filteringData" />

    <template v-else>
      <EmptyState v-if="noData" />
      <template v-else>
        <!-- Following -->
        <PeopleCollapse
          :collection="filteredData.followings"
          title="Following"
          accent="purple"
          class="mb-10"
          #default="{ collection }"
        >
          <keep-alive>
            <component
              :is="viewType == 'grid' ? 'PeopleListCovers' : 'PeopleList'"
              :data="collection"
              instance="followings"
              :send-message="sendMessage"
              :generate-link="($event)=> ({ name: 'myPeoplePersonProfile', params: { id: $event.id } })"
              :unfollow="unFollow"
            >
              <template #unfollow-btn="{ personId }">
                <!-- Unfollow btn -->
                <v-btn
                  width="123px"
                  outlined
                  rounded
                  color="#8B78FE"
                  height="32"
                  @click="unFollow({ id: personId, instance: 'followings' })"
                >
                  {{ $i18n.t("mylives.my_people.unfollow_btn") }}
                </v-btn>
              </template>
            </component>
          </keep-alive>
        </PeopleCollapse>

        <!-- Follows me -->
        <PeopleCollapse
          :collection="filteredData.followers"
          title="Follows me"
          accent="orange"
          #default="{ collection }"
        >
          <PeopleList
            :send-message="sendMessage"
            instance="followers"
            :unfollow="unFollow"
            :data="collection"
          />
        </PeopleCollapse>
      </template>
    </template>
  </v-container>
</template>

<script>
import { mapActions, mapMutations, mapState, mapGetters } from 'vuex'

import SelectViewType from '@/components/Elements/SelectViewType.vue'
import EmptyState from "@/components/MyPeople/EmptyState.vue"
import PeopleList from '@/components/MyPeople/PeopleList.vue'
import PeopleListCovers from '@/components/MyPeople/PeopleListCovers.vue'
import PeopleCollapse from "@/components/MyPeople/PeopleCollapse.vue"
import PeopleListCoversLoader from "@/components/MyPeople/PeopleListCoversLoader"

import VSearch from "@/components/Elements/Forms/Search";

import storeModule from "@/store/modules/my-people.js"
import { delay } from '@/utils/functions'

export default {
  name: "MyPeople",
  components: { SelectViewType, EmptyState, PeopleList, PeopleListCovers, PeopleCollapse, PeopleListCoversLoader, VSearch },
  data() {
    return {
      search: '',
      filteringData: false,

      viewType: "grid",

    }
  },
  computed: {
    ...mapState('myPeople', ['followings', 'followers', 'loading']),
    ...mapGetters('myPeople', ['totalFollow']),
    filteredData() {
      const compare = (str, query) => str.toLowerCase().includes(query.trim().toLowerCase())
      const filterByNameName = ({ attributes }) => compare(attributes.nickname, this.search)

      return {
        followings: this.followings.data.filter(filterByNameName),
        followers: this.followers.data.filter(filterByNameName)
      }
    },
    noData() {
      return !this.followings.data.length && !this.followers.data.length
    }
  },
  created() {
    const store = this.$store;
    // register a new module only if doesn't already exist
    if (!(store.state?.["myPeople"])) {
      store.registerModule("myPeople", storeModule);
    } else {
      // re-use the already existing module
      console.info(`reusing module: "myPeople"`);
    }

    // load followings and followers
    this.loadData()
  },
  methods: {
    ...mapMutations('myPeople', {
      setLoading: 'SET_LOADING'
    }),
    ...mapActions('myPeople', ['getFollowers', 'getFollowings', 'unFollow']),
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    showInviteModal() {
      this.setDialog({
        title: this.$i18n.t('mylives.invitations.invite_dialog.title'),
        component: 'MyLifeInviteDialog',
        size: 'big',
      })
    },
    sendMessage(userId, familyId) {
      this.setDialog({
        component: 'SendMessageToMembersDialog',
        title: this.$i18n.t('requests.title'),
        data: {
          kinshipsIds: [userId],
          familyId,
          locked: true
        }
      })
    },
    setViewType(type) {
      if (this.viewType === type) return

      this.viewType = type

      //   TODO add local storage caching
    },
    async loadData() {
      try {
        this.setLoading(true)
        const params = this.getShowcaseOptions()

        await Promise.all([this.getFollowings(params), this.getFollowers(params)])

        // delay to produce better user experience without jumping content
        await delay(350)
      } finally {
        this.setLoading(false)
      }
    },
    getShowcaseOptions() {
      const result = {}
      if (localStorage.getItem('tour')) {
        result.showcase = true
      }

      return result
    },
    async filterResults({ query }) {
      this.search = query

      try {
        if (query !== '') {
          this.filteringData = true

          // delay to produce better user experience without jumping content
          await delay(350)
        }

      } finally {
        this.filteringData = false
      }
    }
  }
}
</script>
<style lang="scss">
.people-search {
  width: 264px;

  .v-icon {
    color: $secondary !important;
  }
  fieldset {
    border-color: $secondary !important;
  }
}

.people-container {
  @include container-grid-size();
}

.people-header {
  padding-top: 12px;

  &__subtitle {
    font-family: Enriqueta;
    font-style: normal;
    font-weight: bold;
    font-size: 23px;
    color: $primary-grey;
  }
  &__dot {
    margin-top: 8px;
    width: 6px;
    height: 6px;
    margin-right: 7px;
    border-radius: 50%;
    margin-left: 6px;
    background: $primary-grey;
  }
}
</style>

