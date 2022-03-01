<template>
  <div
    id="user-profile"
    class="page-container"
  >
    <div>
      <portal to="submenu">
        <profile-submenu
          :kinship="kinship"
          :edit-mode.sync="editMode"
          :show-edit="showEdit"
          :selected-family-id="currentFamilyId"
          @family-filter-changed="familyChanged($event)"
          @onChangeViewtype="handleChangedViewType"
        />
      </portal>
      <section class="family-stories page-blocks-holder">
        <ul
          v-if="stories.length && !updateViewType"
          class="stories blocks"
          infinite-wrapper
        >
          <story-block
            v-for="story in stories"
            :key="story.id"
            :story="story"
          />
        </ul>

        <ul
          v-if="stories.length && updateViewType"
          class="stories blocks"
          infinite-wrapper
        >
          <div class="tableWrap">
            <table>
              <thead>
                <th>Image</th>
                <th>Title</th>
                <th>Description</th>
                <th>Community</th>
                <th>Chapters</th>
                <th>Collaborators</th>
                <th>Created</th>
                <th>Updated</th>
                <th>Period</th>
                <th class="mw190">
                  Action
                </th>
              </thead>
              <tbody>
                <profileStoryList
                  v-for="story in stories"
                  :key="story.id"
                  :story="story"
                />
              </tbody>
            </table>
          </div>
        </ul>

        <div
          v-else-if="!stories.length && !isLoading"
          class="message-container"
        >
          <div
            class="inner"
          >
            <p class="message">
              {{ $i18n.t('stories.empty_index') }}
            </p>
            <a
              href=""
              :title="$i18n.t('stories.new_title')"
              @click.prevent="createStory"
            >
              {{ $i18n.t('stories.new') }}
            </a>
          </div>
        </div>
        <stories-loader v-if="isLoading" />
        <infinite-loading
          v-if="hasMorePages"
          spinner="spiral"
          force-use-infinite-wrapper
          @infinite="loadMore"
        >
          <div slot="no-more" />
        </infinite-loading>
      </section>
    </div>
  </div>
</template>

<script>
import {mapActions, mapGetters, mapState} from 'vuex'

import StoryBlock from '../Story/legacy/story-block'
import StoriesLoader from '../Story/StoryCardLoader'
import ProfileSubmenu from './profile-submenu'
import profileStoryList from './profile-story-list'

import { storiesMixin } from '../../mixins/stories_mixin'

export default {
  name: 'UserStory',
  components: { StoryBlock, StoriesLoader, ProfileSubmenu, profileStoryList },
  mixins: [storiesMixin],
  beforeRouteEnter (to, from, next) {
    next(vm => {
      vm.foeBeforeRoute(from.name)
      next()
    })
  },
  data () {
    return {
      beforeRoute: '',
      updateViewType: false,
      otherFilter: false,
      kinshipId: this.$route.params.id &&
          this.$route.params.id.toString(),
      editMode: false,
      showEdit: false,
      filters: {
        type: (() => {
          console.log(this.$route.params)
          return this.$route.params.familyType !== undefined
            ? this.$route.params.familyType
            : 'draft'
        })(),
        author: this.$route.query.user ? parseInt(this.$route.query.user) : '',
        category: ''
      }
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      // TODO-SELECTED-FAMILY-ID: use correct family id
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    }),
    ...mapGetters({
      isLoading: 'stories/isLoading',
      isError: 'stories/isError',
      currentPage: 'stories/currentPage',
      totalPages: 'stories/totalPages',
      allTags: 'stories/allTags',
      stories: 'stories/all',
      loadKinship: 'kinships/load',
      getFamilyType: 'stories/getFamilyType'
    }),
    kinship () {
      return this.loadKinship(this.kinshipId)
    },
    hasMorePages () {
      return this.currentPage && this.currentPage < this.totalPages
    },
    currentFamilyId () {
      if (this.filters.type === 'draft') return 'draft'
      if (this.filters.type === '') return 'all'
      return this.chosenFamilyId
    },
    filterFamilyId () {
      if (this.filters.type === 'draft' || this.filters.type === '') {
        return ''
      } else {
        return this.chosenFamilyId
      }
    },
    queryParams () {
      return {
        ...this.filters,
        family: this.filterFamilyId,
        author: this.kinshipId
          ? this.kinship.attributes.user_id
          : this.currentUser.id
      }
    }
  },
  watch: {
    queryParams () {
      this.loadStoriesWithFilters()
    }
  },
  mounted () {
    this.fetchKinship()
    this.loadStoriesWithFilters()
  },
  methods: {
    ...mapActions({
      loadStories: 'stories/loadNext',
      clearStories: 'stories/clearStories',
      findKinship: 'kinships/findRecord'
    }),
    foeBeforeRoute (value) {
      this.beforeRoute = value
    },
    handleChangedViewType (value) {
      this.updateViewType = value
    },
    async fetchKinship () {
      let params = {
        options: {
          include: 'family'
        }
      }
      if (this.$route.params.id) {
        params['id'] = this.$route.params.id.toString()
      } else {
        params['familyId'] = this.chosenFamilyId
      }

      try {
        const { data } = await this.findKinship(params)
        this.kinshipId = data.id
      } catch (error) {
        console.error(error)
      }
    },
    async loadMore ($state) {
      let params = { ...this.queryParams }
      try {
        await this.loadStories(params)
        $state.loaded()
        if (!this.hasMorePages) $state.complete()
      } catch (e) {
        console.error(e)
        $state.complete()
      }
    },
    loadStoriesWithFilters () {
      this.clearStories()
      let params = { ...this.queryParams, page: 1 }
      this.loadStories(params)
    },
    familyChanged (familyID) {
      if (familyID === 'all') {
        this.filters.type = ''
      } else if (familyID === 'draft') {
        this.filters.type = 'draft'
      } else {
        this.filters.type = 'published'
      }
    }
  }
}
</script>

<style lang="scss" scoped>
th {
  font-size: 18px;
  text-align: center;
  min-width: 125px;
}

.tableWrap {
  height: 100%;
  max-height: calc(100vh - 27vh);
  overflow: auto;
  margin-top: 12px;
}

thead th {
  position: sticky;
  top: 0;
  background-color: white;
}

table {
  border-collapse: collapse;
}

.mw190 {
  min-width: 190px;
}
</style>
