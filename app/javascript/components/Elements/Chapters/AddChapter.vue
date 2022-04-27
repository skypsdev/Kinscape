<template>
  <div class="d-flex">
    <template v-if="separator">
      <v-btn
        v-bind="$attrs"
        class="add-chapter-button pl-0"
        color="primary"
        text
        @click="handleCreateNewChapter"
      >
        <v-icon class="mr-2">mdi-plus-circle-outline</v-icon>
        {{$i18n.t('stories.chapters.new')}}
      </v-btn>
      <hr class="dotted-line" />
    </template>

    <template v-else>
      <v-btn
        v-bind="$attrs"
        rounded
        large
        elevation="0"
        color="primary"
        @click="handleCreateNewChapter"
      >
        <v-icon class="mr-2">mdi-plus-circle-outline</v-icon>
        {{$i18n.t('stories.chapters.new')}}
      </v-btn>
    </template>
  </div>
</template>
<script>
import { mapActions, mapState, mapGetters } from 'vuex'

export default {
  props: {
    position: {
      type: Number,
      required: true
    },
    separator: {
      type: Boolean,
      default: false
    },
    viewType: {
      type: String,
      required: true
    },
    editMode: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapGetters({
      activeTooltip: 'core/activeTooltip'
    }),
    ...mapState({
      member: state => state.members.member,
      community: state => state.families.community,
      story: state => state.stories.story
    })
  },
  methods: {
    ...mapActions({
      createNewMemberChapter: 'members/createNewChapter',
      createNewCommunityChapter: 'families/createNewChapter',
      createNewStoryChapter: 'stories/createNewChapter',

    }),
    async handleCreateNewChapter () {
      let params = {
        position: this.position,
        title: this.$i18n.t('sections.title_placeholder'),
        rich_body: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
      }
      if (this.viewType === 'member') {
        if (!this.editMode) {
          await this.$router.push({ name: 'memberEdit', params: { id: this.member.id } })
        }
        params = {
          object_id: this.member.id,
          object_type: 'Kinship',
          ...params
        }
        this.createNewMemberChapter(params)
      } else if (this.viewType === 'community') {
        if (!this.editMode) {
          await this.$router.push({ name: 'community', params: { id: this.community.id } })
        }
        params = {
          object_id: this.community.id,
          object_type: 'Family',
          ...params
        }
        this.createNewCommunityChapter(params)
      } else {
        if (!this.editMode) {
          await this.$router.push({ name: 'editStory', params: { id: this.story.publicationId } })
        }
        this.createNewStoryChapter(params)
      }
    }
  }
}
</script>
<style lang="scss">
.add-chapter-button::before {
  display: none !important;
}
.dotted-line {
  display: inline-block;
  border-top: 1px dotted #534898;
  width: 100%;
  margin-top: 20px;
}
</style>
