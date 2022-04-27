<template>
  <div
      v-bind="$attrs"
      id="table-of-contents"
      class="table-of-contents d-flex flex-column overflow-y-auto"
  >
  
    <h4
        v-if="hasItems"
        class="table-of-contents-title text-left mb-1">
      {{ $i18n.t("stories.table_of_sections.title") }}
    </h4>
    <div
        v-if="hasItems"
        class="table-of-contents-wrapper overflow-y-auto mb-3"
        :class="{'table-of-contents-wrapper--editable': isEditable}"
    >
      <ul
          class="chapter-list"
          v-sortable="{
          onUpdate: updateSectionPosition,
          handle: '.reorder-section'
        }"
      >
        <li
            v-for="link in links"
            :key="link.id"
            class="chapter mb-2"
        >
          <a
              v-if="isEditable"
              class="reorder-section"
              :title="$i18n.t('communities.table_of_contents.link_title')"
          >
            <i class="fa fa-arrows-v" />
          </a>
          <a @click="setActiveChapter(link.id)">
            <span class="chapter__index pr-2" v-text="link.position + 1" />
            <span class="chapter__title">{{ link.title | truncate(100) }}</span>
          </a>
        </li>
      </ul>
    </div>

    <Tooltip
      v-if="isEditable || addChapterEnabled"
      position="bottom right"
      name="addChapter"
      :icons="['mdi-plus-circle-outline']"
      :title="$i18n.t('tooltips.add_chapter_title')"
      :description="$i18n.t('tooltips.add_chapter_description')"
    >
      <template #activator="{ attrs }">
        <AddChapter
          v-bind="attrs"
          :view-type="dataType"
          :position="links.length"
          :edit-mode="isEditMode"
          class="mb-3 align-self-center"
        />
      </template>
    </Tooltip>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import debounce from 'lodash/debounce'

import AddChapter from "./AddChapter"
import Tooltip from '@/components/Elements/Tooltip.vue'
import filters from '@/utils/filters'

export default {
  filters: {
    truncate: filters.truncate,
  },
  components: {
    AddChapter,
    Tooltip
  },
  props: {
    isEditMode: {
      type: Boolean,
      default: false
    },
    dataType: {
      type: String,
      required: true
    },
    addChapterEnabled: {
      type: Boolean,
      default: false
    },
    isChanged: Boolean
  },
  computed: {
    ...mapState({
      member: store => store.members.member,
      community: store => store.families.community,
      story: store => store.stories.story,
      memberChapters: store => store.members.chapters,
      communityChapters: store => store.families.chapters,
      storyChapters: store => store.sections.all
    }),
    links() {
      const links = this?.[this.dataType]?.content?.links ?? []
      return links.sort((curr, prev) => curr.position - prev.position)
    },
    hasItems() {
      return this.links.length
    },
    storyCanEdit() {
      return this.$possible('manage', 'Publication', { story: { userId: this.story.userId } })
    },
    memberCanEdit() {
      return this.$possible('manage', 'Kinship', { userId: this.member.userId })
    },
    communityCanEdit() {
      return this.$possible('manage', 'Family', { id: this.community.id })
    },
    isEditable() {
      return this[`${this.dataType}CanEdit`] && this.isEditMode
    }
  },
  methods: {
    ...mapActions({
      storyLoadSections: 'sections/loadNext',
      memberSetActiveChapter: 'members/setActiveChapter',
      communitySetActiveChapter: 'families/setCommunityActiveChapter',
      memberUpdateChapter: 'members/updateChapter',
      storySetActiveChapter: 'stories/setStoryActiveChapter',
      communityUpdateChapter: 'families/updateChapter',
      storyUpdateChapter: 'stories/updateChapter'
    }),
    setActiveChapter(linkId) {
      this[`${this.dataType}SetActiveChapter`](linkId)
    },
    async updateSectionPosition (event) {
      if (this.dataType === 'story') {
        while (this.storyChapters.length < (event.oldIndex + 1)) {
          await this.storyLoadSections({id: this.story.publication.id})
        }
      }
      const section = this[`${this.dataType}Chapters`][event.oldIndex]
      section.attributes.position = event.newIndex
      section.attributes.title = this[this.dataType].content.links[event.oldIndex].title
      section.attributes.object_type = this.dataType === 'member' ? 'Kinship' : 'Family'
      section.attributes.object_id = this[this.dataType].id

      this[`${this.dataType}Chapters`].splice(event.newIndex, 0,
          this[`${this.dataType}Chapters`].splice(event.oldIndex, 1)[0])

      this.saveChapterChanges(this, section)
    },
    saveChapterChanges: debounce((ctx, section) => {
      ctx[`${ctx.dataType}UpdateChapter`]({
        id: section.id,
        form: section.attributes
      })
    }, 700)
  }
}
</script>

<style lang="scss" scoped>
.table-of-contents {
  width: 100%;
  max-width: 208px;
  flex-grow: 1;

  display: flex;
  flex-direction: column;
  align-items: stretch;
}
.table-of-contents-title {
  font-family: Enriqueta;
  font-weight: bold;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: -0.02em;
}
.table-of-contents-wrapper {
  flex-grow: 1;
  width: 100%;
  background: $color-dark-white;
  padding: 8px 8px 8px 16px;
  position: relative;
  a {
    cursor: pointer;
  }
}
.chapter-list {
  list-style: none;
  padding-left: 0;
}
.chapter {
  display: list-item !important;
  position: relative;
  &__index {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 30px;
    color: $color-required;
  }
  &__title {
    font-family: Lato;
    font-style: normal;
    font-weight: 400;
    font-size: 16px;
    line-height: 24px;
    color: $color-tertiary;
  }
}
.reorder-section {
  cursor: move;
  padding-right: 8px;
  border: 1px solid $disabled-grey;
  padding-left: 8px;
  margin-right: 10px;
  border-radius: 1px;
  background-color: $disabled-grey;
  position: absolute;
  left: -40px;
}
.reorder-section:hover, .reorder-section.active {
  background-color: $color-required;
  border-color: $color-required;
  color: #fff;
  z-index: 3;
}
</style>
