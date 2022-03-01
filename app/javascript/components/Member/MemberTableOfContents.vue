<template>
  <div
      id="table-of-contents"
      class="table-of-contents"
      v-if="member.content.links.length"
  >
    <div
        class="table-of-contents-wrapper"
        :class="{'table-of-contents-wrapper--editable': isEditMode}"
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
              v-if="isEditMode"
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
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import filters from '../../utils/filters'
import debounce from 'lodash/debounce'

export default {
  filters: {
    truncate: filters.truncate,
  },
  props: {
    isEditMode: {
      type: Boolean,
      default: false
    },
    isChanged: Boolean
  },
  computed: {
    ...mapState({
      member: store => store.members.member,
      chapters: store => store.members.chapters
    }),
    links() {
      const links = this.member.content.links
      return links.sort((curr, prev) => curr.position - prev.position)
    }
  },
  methods: {
    ...mapActions({
      setActiveChapter: 'members/setActiveChapter',
      updateChapter: 'members/updateChapter'
    }),
    async updateSectionPosition (event) {
      const section = this.chapters[event.oldIndex]
      section.attributes.position = event.newIndex
      section.attributes.object_type = 'Kinship'
      section.attributes.object_id = this.member.id

      this.chapters.splice(event.newIndex, 0,
          this.chapters.splice(event.oldIndex, 1)[0])
      this.saveChapterChanges(this, section)
    },
    saveChapterChanges: debounce((ctx, section) => {
      ctx.updateChapter({
        id: section.id,
        form: section.attributes
      })
    }, 700)
  }
}
</script>

<style lang="scss" scoped>
.table-of-contents {
  min-height: 118px;
  width: 100%;
}
.chapter-list {
  list-style: none;
  padding-left: 0;
}
.table-of-contents-wrapper {
  width: 100%;
  background: #F7F7F7;
  padding: 8px 8px 8px 16px;
  &--editable {
    padding: 8px 8px 8px 46px;
  }
  position: relative;
  a {
    cursor: pointer;
  }
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
    color: #E95631;
  }
  &__title {
    font-family: Lato;
    font-style: normal;
    font-weight: 400;
    font-size: 16px;
    line-height: 24px;
    color: #4B4B4B;
  }
}
.reorder-section {
  cursor: move;
  padding-right: 8px;
  border: 1px solid #E6E6E6;
  padding-left: 8px;
  margin-right: 10px;
  border-radius: 1px;
  background-color: #E6E6E6;
  position: absolute;
  left: -40px;
}
.reorder-section:hover, .reorder-section.active {
  background-color: #E95631;
  border-color: #E95631;
  color: #fff;
  z-index: 3;
}
</style>
