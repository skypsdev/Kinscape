<template>
  <section>
    <Tooltip
      v-if="isCommunities"
      position="bottom left"
      name="newCommunity"
      :icons="['mdi-plus-circle-outline']"
      :title="$i18n.t('tooltips.new_community_title')"
      :description="$i18n.t('tooltips.new_community_description')"
    >
      <template #activator="{ attrs }">
        <v-btn
          v-bind="attrs"
          text
          class="app-bar-button app-bar-button--new-story"
          id="intro-communities-new-community"
          title="Start a New Community"
          @click="openAddCommunityDialog"
        >
          <v-icon>mdi-plus-circle-outline</v-icon>
          <div>
            {{ $i18n.t('families.new') }}
          </div>
        </v-btn>
      </template>
    </Tooltip>
    <Tooltip
      v-else
      position="bottom left"
      name="newStory"
      :icons="['mdi-plus-circle-outline']"
      :title="$i18n.t('tooltips.new_story_title')"
      :description="$i18n.t('tooltips.new_story_description')"
    >
      <template #activator="{ attrs }">
        <v-btn
          v-bind="attrs"
          text
          id="intro-stories-new-story"
          class="app-bar-button app-bar-button--new-story"
          :title="$i18n.t('stories.new')"
          @click="openNewStoryDialog"
        >
          <v-icon>mdi-plus-circle-outline</v-icon>
          <div>{{ $i18n.t('stories.new') }}</div>
        </v-btn>
      </template>
    </Tooltip>
  </section>
</template>
<script>
import { mapActions } from 'vuex'
import Tooltip from '@/components/Elements/Tooltip.vue'

export default {
  components: {
    Tooltip
  },
  computed: {
    isCommunities() {
      return this.$route.name === 'communities';
    },
  },
  mounted () {
    this.$nextTick(() => {
      this.tip = true
    })
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    openNewStoryDialog() {
      this.setDialog({
        component: 'NewStoryFormDialog',
        title: this.$i18n.t('stories.newStoryDialog.title'),
        size: 'big'
      })
    },
    openAddCommunityDialog() {
      this.setDialog({
        title: this.$i18n.t('families.new'),
        component: 'AddCommunityDialog'
      })
    }
  }
}
</script>
