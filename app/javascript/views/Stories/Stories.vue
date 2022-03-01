<template>
  <div class="stories pt-6">
    <div
      v-if="stories.viewType === 'grid'"
      class="stories__grid"
    >
      <div class="stories__toolbar d-flex flex-wrap my-3">
        <FilterByCategory class="my-1"/>
        <FilterByAuthor v-if="!isMyStories" class="my-1 ml-sm-2"/>
        <ClearFilters  class="my-1 ml-sm-2" />
        <v-spacer/>
        <Sorting :sorting-action="setStorySorting" class="my-1"/>
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
          <StoryCard :story="story"/>
        </div>
      </div>
      <StoryCardLoader />
    </div>

    <div class="stories__grid">
      <section>
        <StoryListView
            v-if="stories.allStories.length && stories.viewType === 'list'"
            :stories="stories.allStories"
        />

        <div
          v-else-if="!stories.allStories.length && !stories.loading"
          class="message-container"
        >
          <div
            v-if="stories.filters.query && stories.filters.query.length"
            class="inner animated empty-search"
          >
            <p class="message" v-text="$i18n.t('stories.empty_search')" />
          </div>
          <div v-else class="inner">
            <p class="message" v-text="$i18n.t('stories.empty_index')" />
            <a
              href=""
              :title="$i18n.t('stories.new_title')"
              @click.prevent="createStory"
            >
              {{ $i18n.t('stories.new') }}
            </a>
          </div>
        </div>
        </section>
    </div>

  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'

import FilterByAuthor from '../../components/Toolbars/Stories/FilterByAuthor'
import FilterByCategory from '../../components/Toolbars/Stories/FilterByCategory'
import ClearFilters from '../../components/Toolbars/Stories/ClearFilters'
import Sorting from "@/components/Toolbars/Stories/Sorting"
import StoryCard from '../../components/Story/StoryCard'
import StoryListView from "../../components/Story/StoryListView"
import StoryCardLoader from '../../components/Story/StoryCardLoader'

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
    }),
    isMyStories() {
      return ['private_stories', 'shared_stories'].includes(this.stories.filters.publicationVisibility)
    }
  },
  watch: {
    '$route.query' (query) {
      if (!Object.keys(query).length) {
        this.clearStoryFilters()
        this.setStorySorting()
      }
      this.getNewStories()
    }
  },
  async mounted () {
    if (this.$route.name === 'invitation') {
      this.getInvitation(this.$route.params.id).then((res) => {
        if (res.data && res.data?.attributes?.newcomer) {
          this.showWelcomeDialog()
        } else if (res.data) {
          this.showJoinDialog()
        }
      }).catch((err) => {
        console.error(err)
        this.setSnackbar(err.message)
      })
    }
    const filters = {...this.$route.query}
    delete filters.sortBy
    delete filters.sortDirection
    this.setStoryFilters(filters)
    const {sortBy, sortDirection} = this.$route.query
    this.setStorySorting({sortBy, sortDirection})
    this.getNewStories()
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
    getNewStories () {
      this.clearStories()
      this.getPublications({ page: 1 })
    },
    createStory() {
      this.setDialog({
        component: 'NewStoryFormDialog',
        title: this.$i18n.t('stories.newStoryDialog.title'),
        size: 'big'
      })
    },
    showWelcomeDialog() {
      this.setDialog({
        component: 'SignUpWelcomeDialog',
        isToolbarHidden: true,
        size: 'big'
      })
    },
    showJoinDialog() {
      this.setDialog({
        title: this.$i18n.t('welcome.existing_profile_title'),
        component: 'SignUpExistingUserInvitationDialog',
        size: 'big'
      })
    }
  }
}
</script>

<style lang="scss" scoped>
@mixin container-grid-size() {
  $cover_width: 288px;
  $min_col_width: 600px;
  width: $cover_width;
  @for $i from 0 to 6 {
    @media screen and (min-width: $min_col_width + $cover_width * $i) {
      width: $cover_width * ($i + 2);
      @if $i > 1 {
        padding: 0 156px;
      }
    }
  }
}

.stories {
  &__grid {
    padding: 0 12px;
    margin: 0 auto;
    @include container-grid-size();
  }
  &__covers {
    margin-left: -12px;
    margin-right: -12px;
  }
}
</style>
