<template>
  <Breadcrumbs :items="items"/>
</template>
<script>
import {mapActions, mapState} from 'vuex'
import Breadcrumbs from "@/components/Toolbars/Breadcrumbs";

export default {
  components: { Breadcrumbs },
  computed: {
    ...mapState({
      story: state => state.stories.story,
      families: state => state.families.simpleList.families
    }),
    items() {
      return [
        {
          label: this.$i18n.t('header.stories'),
          icon: 'mdi-text-box-outline',
          to: '/stories',
        },
        {
          label: this.community.name || this.$i18n.t('stories.private_stories'),
          icon: this.community.id ? 'mdi-account-multiple-outline' : 'mdi-lock-outline',
          list: this.allPublications,
        },
        {
          label: this.story.title,
          icon: this.isEditMode ? 'mdi-pencil-outline' : '',
        },
      ]
    },
    community() {
        return this.story.community.id ? this.story.community : {}
    },
    allPublications() {
      return this.story.publication?.attributes?.allPublications || []
    },
    isEditMode() {
      return this.$route.name === 'editStory'
    },
  },
  mounted () {
    this.updateChapterList(this.links)
  },
  methods: {
    ...mapActions({
      updateChapterList: 'stories/updateChapterList'
    }),
  }
}
</script>
