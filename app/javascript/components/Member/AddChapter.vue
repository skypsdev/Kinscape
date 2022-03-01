<template>
  <div class="d-flex">

    <template v-if="separator">
      <v-btn
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
import { mapActions, mapState } from 'vuex'

export default {
  props: {
    position: {
      type: Number,
      required: true
    },
    separator: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    ...mapState({
      member: state => state.members.member,
    })
  },
  methods: {
    ...mapActions({
      createNewChapter: 'members/createNewChapter',
    }),
    handleCreateNewChapter () {
      const params = {
        object_id: this.member.id,
        object_type: 'Kinship',
        media_type: 'text',
        position: this.position,
        title: this.$i18n.t('sections.title_placeholder'),
        rich_body: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
      }
      this.createNewChapter(params)
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
