<template>
  <div class="chapter-list">
    <li
      v-for="(link, index) in getChapterList"
      :key="index"
      class="chapter"
    >
      <a
        v-if="isEditMode === true"
        class="reorder-section"
        title="Move Content Up / Down"
      >
        <i class="fa fa-arrows-v" />
      </a>
      <a
        :data-text="link.text"
        @click="goToSection(index)"
      >
        {{ index + 1 }}. {{ link.text }}
      </a>
    </li>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
export default {
  props: {
    links: {
      type: Array,
      required: true
    },
    isEditMode: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapGetters({
      getChapterList: 'kinships/getChapterList'
    })
  },
  mounted () {
    this.updateChapterList(this.links)
  },
  methods: {
    ...mapActions({
      updateChapterList: 'kinships/updateChapterList'
    }),
    elementSelector (index) {
      return '.content-wrapper .chapter_data:nth-child(' + (index + 1) + ')'
    },
    async goToSection (index) {
      let temp = false
      const selector = this.elementSelector(index)

      while (!document.querySelector(selector)) {
        // await this.loadSections(this.storyId)
        temp = true
      }

      if (temp) {
        var vm = this
        setTimeout(function () {
          vm.$scrollTo(selector, 500, { offset: -180 })
        }, 2000)
        temp = false
      } else {
        this.$scrollTo(selector, 500, { offset: -180 })
      }
    }
  }
}
</script>

<style lang="scss" scoped>
  .chapter {
    display: list-item !important;
  }
  .reorder-section {
    cursor: move;
    padding-right: 8px;
    border: 1px solid #dbe0e7;
    padding-left: 8px;
    margin-right: 10px;
    border-radius: 3px;

  }
  .reorder-section:hover, .reorder-section.active {
    background-color: #8B78FE;
    border-color: #8B78FE;
    color: #fff;
    z-index: 3;
}
</style>
