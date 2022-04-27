<template>
  <div class="mt-10" infinite-wrapper>
    <v-row class="story-list__header mb-4 pa-0">
      <v-col cols="3" class="story-list__header-col pa-0 pl-4 d-flex align-center">Story Title</v-col>
      <v-col cols="1" class="story-list__header-col d-flex align-center">Created</v-col>
      <v-col cols="1" class="story-list__header-col d-flex align-center">Updated</v-col>
      <v-col cols="2" class="story-list__header-col d-flex align-center">Time Period</v-col>
      <v-col cols="2" class="story-list__header-col d-flex align-center">Categories</v-col>
      <v-col class="story-list__header-col d-flex align-center">Author</v-col>
    </v-row>
    <StoryListItem
        v-for="story in stories"
        :key="story.publication.id"
        :story="story"
    />
  </div>
</template>
<script>
import StoryListItem from './StoryListItem'

export default {
  components: { StoryListItem },
  props: {
    stories: {
      type: Array,
      required: true
    }
  },
}
</script>
<style lang="scss" scoped>
.story-list {
  &__header {
    background: $color-light-grey;
    border-radius: 5px;
    height: 40px;
  }
  &__header-col {
    max-height: 40px;
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 16px;
    line-height: 21px;
    color: $color-tertiary;
  }
}
</style>
