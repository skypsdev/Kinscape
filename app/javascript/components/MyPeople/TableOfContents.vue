<template>
  <div
    id="table-of-contents"
    class="table-of-contents d-flex flex-column overflow-y-auto mt-9"
  >
    <h4 class="table-of-contents-title text-left mb-1">
      {{ $i18n.t("stories.table_of_sections.title") }}
    </h4>

    <div class="table-of-contents-wrapper overflow-y-auto mb-3">
      <ul class="chapter-list">
        <li v-for="link in linksSorted" :key="link.id" class="chapter mb-2">
          <a
            @click="setActiveChapter(link.id)"
            :class="link.id == activeChapter && 'chapter__link--active'"
          >
            <span class="chapter__index pr-2" v-text="link.position + 1" />
            <span class="chapter__title">{{ truncate(link.title) }}</span>
          </a>
        </li>
      </ul>
    </div>
  </div>
</template>

<script>
import filters from '@/utils/filters'
import { sortBy as _sortBy } from 'lodash'

export default {
  props: {
    setActiveChapter: {
      type: Function, default: () => null, required: true
    },
    activeChapter: {
      type: String, default: "", required: true
    },
    links: {
      type: Array, default: () => []
    }
  },
  computed: {
    linksSorted() {
      return _sortBy(this.links, ['position'])
    }
  },
  methods: {
    truncate: t => filters.truncate(t, 100)
  }
}
</script>

<style lang="scss" scoped>
.table-of-contents {
  width: 100%;
  max-width: 208px;
}
.table-of-contents-title {
  font-family: Enriqueta;
  font-weight: bold;
  font-size: 24px;
  line-height: 32px;
  letter-spacing: -0.02em;
  color: #4b4b4b;
}
.table-of-contents-wrapper {
  width: 100%;
  background: $color-dark-white;
  padding: 8px 8px 8px 16px;
  &--editable {
    padding: 8px 8px 8px 46px;
  }
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
    color: $secondary;
  }
  &__title {
    font-family: Lato;
    font-style: normal;
    font-weight: 400;
    font-size: 16px;
    line-height: 24px;
    color: $color-tertiary;
  }
  &__link--active .chapter__title {
    color: $secondary;
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
.reorder-section:hover,
.reorder-section.active {
  background-color: $color-required;
  border-color: $color-required;
  color: #fff;
  z-index: 3;
}
</style>
