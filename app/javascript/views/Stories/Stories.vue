<template>
  <div class="stories pt-6">
    <div
      v-if="stories.viewType === 'grid'"
      class="stories__grid"
    >
      <div class="stories__toolbar d-flex flex-wrap my-3">
        <FilterByCategory class="my-1" />
        <FilterByAuthor
          v-show="filtersByAuthorIsVisible"
          class="my-1 ml-sm-2"
        />
        <ClearFilters class="my-1 ml-sm-2" />
        <v-spacer />
        <Sorting
          :sorting-action="setStorySorting"
          class="my-1"
        />
      </div>
      <div
        v-if="stories.allStories.length"
        class="stories__covers d-flex flex-wrap justify-start"
      >
        <div
          v-for="story in stories.allStories"
          :key="story.publication.id"
          class="pa-3"
        >
          <StoryCard :story="story" />
        </div>
      </div>
      <StoryCardLoader />
    </div>

    <v-container class="stories__grid">
      <section>
        <StoryListView
          v-if="stories.allStories.length && stories.viewType === 'list'"
          :stories="stories.allStories"
        />

        <div
          v-else-if="!stories.allStories.length && !stories.loading"
        >
          <div
            v-if="stories.filters.query && stories.filters.query.length"
            class="inner animated empty-search"
          >
            <p
              class="message"
              v-text="$i18n.t('stories.empty_search')"
            />
          </div>
          <div
            v-else
            class="inner"
          >
            <p
              class="message"
              v-text="$i18n.t('stories.empty_index')"
            />
            <a
              href=""
              :title="$i18n.t('stories.new_title')"
              @click.prevent="createStory"
            >
              {{ $i18n.t("stories.new") }}
            </a>
          </div>
        </div>
      </section>
    </v-container>

    <infinite-loading
      v-if="hasMorePages"
      spinner="spiral"
      force-use-infinite-wrapper
      @infinite="getMoreStories"
    >
      <div slot="no-more" />
    </infinite-loading>
  </div>
</template>

<script>
import { mapActions, mapState, mapGetters } from 'vuex'

import FilterByAuthor from '@/components/Toolbars/Stories/FilterByAuthor'
import FilterByCategory from '@/components/Toolbars/Stories/FilterByCategory'
import ClearFilters from '@/components/Toolbars/Stories/ClearFilters'
import Sorting from "@/components/Toolbars/Stories/Sorting"
import StoryCard from '@/components/Story/StoryCard'
import StoryListView from "@/components/Story/StoryListView"
import StoryCardLoader from '@/components/Story/StoryCardLoader'
import { storiesShowCaseConfig, storiesShowCaseData } from '@/plugins/showcaseStaticData'

export default {
  name: 'Stories',
  components: {
    FilterByAuthor,
    FilterByCategory,
    ClearFilters,
    Sorting,
    StoryCard,
    StoryCardLoader,
    StoryListView
  },
  computed: {
    ...mapState({
      stories: state => state.stories,
      isLoading: state => state.stories.loading
    }),
    ...mapGetters({
      hasMorePages: 'stories/hasMorePages'
    }),
    filtersByAuthorIsVisible() {
      const { query } = this.$route

      return Object.keys(query).includes('hideAuthor') === false
    }
  },
  watch: {
    '$route.query'(query) {
      if (!Object.keys(query).length) {
        this.clearStoryFilters()
        this.setStorySorting()
      }
      this.getNewStories()
    }
  },
  created() {
    this.getFollowings()
  },
  mounted() {
    if (this.$route.name === 'invitation') {
      this.getInvitation(this.$route.params.id).then((res) => {
        if (res.data) {
          this.showJoinDialog()
        }
      }).catch((err) => {
        console.error(err)
        this.setSnackbar(err.message)
      })
    }
    const filters = { ...this.$route.query }
    delete filters.sortBy
    delete filters.sortDirection
    this.setStoryFilters(filters)
    const { sortBy, sortDirection } = this.$route.query
    this.setStorySorting({ sortBy, sortDirection })
    this.getNewStories()


    if (localStorage.getItem('tour') && !localStorage.getItem('fromPreviousTourStep')) {
      this.showTour(1)
    }
  },
  beforeDestroy() {
    this.clearStoryFilters()
  },
  methods: {
    ...mapActions({
      getPublications: 'stories/getPublications',
      getInvitation: 'families/getInvitation',
      clearStories: 'stories/clearStories',
      setStoryFilters: 'stories/setStoryFilters',
      setStorySorting: 'stories/setStorySorting',
      clearStoryFilters: 'stories/clearStoryFilters',
      setDialog: 'layout/setDialog',
      setSnackbar: 'layout/setSnackbar',
    }),
    ...mapActions('myPeople', ['getFollowings']),
    getNewStories() {
      this.clearStories()
       let params = { page: 1 }
      if (localStorage.getItem('tour') || localStorage.getItem('fromPreviousTourStep')) {
        params.showcase = true
      }

      this.getPublications(params)
    },
    async getMoreStories ($state) {
      try {
        await this.getPublications()
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    },
    createStory() {
      this.setDialog({
        component: 'NewStoryFormDialog',
        title: this.$i18n.t('stories.newStoryDialog.title'),
        size: 'big'
      })
    },
    showJoinDialog() {
      this.setDialog({
        title: this.$i18n.t('welcome.existing_profile_title'),
        component: 'SignUpExistingUserInvitationDialog',
        size: 'big'
      })
    },
    showTour(stepNumber = 0) {
      this.$driver
        .init(storiesShowCaseConfig(this))
        .defineSteps(storiesShowCaseData(this.$driver, this))
        .start(stepNumber)
    }
  }
}
</script>

<style lang="scss" scoped>
.stories {
  &__grid {
    @include container-grid-size();
  }
  &__covers {
    margin-left: -12px;
    margin-right: -12px;
  }
}
</style>
