<template>
  <v-row class="list-item mb-2 list-item__action" @click="goToStory">
    <v-col class="pa-0 d-flex flex-row" cols="3">
      <v-img
          :src="storyImage"
          height="48"
          width="48"
          max-width="48"
          class="list-item__img-wrapper mr-3"
      />
      <p class="list-item__title ma-0">{{ story.attributes.title || '-' }}</p>
    </v-col>
    <v-col cols="1" class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ story.attributes.createdAt ? this.$i18n.l('date.formats.default', story.attributes.createdAt) : '-'  }}
      </p>
    </v-col>
    <v-col cols="1" class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ story.attributes.updatedAt ? this.$i18n.l('date.formats.default', story.attributes.updatedAt) : '-'  }}
      </p>
    </v-col>
    <v-col cols="2" class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ timePeriod }}
      </p>
    </v-col>
    <v-col cols="2" class="d-flex flex-row align-center">
      <v-chip
        v-if="story.attributes.categories[0]"
        color="secondary_lightest"
      >
        {{ story.attributes.categories[0] }}
      </v-chip>
      <v-menu
        v-if="story.attributes.categories.length > 1"
        v-model="isDialogShown"
        offset-y
        nudge-left="110"
        nudge-bottom="5"
      >
        <template v-slot:activator="{ on }">
          <v-btn
              class="ml-auto mr-0"
              v-on="on"
              text
          >
            <v-icon>mdi-dots-horizontal</v-icon>
          </v-btn>
        </template>
        <v-card class="pa-2" min-width="168px" max-width="168px" min-height="59px">
          <v-chip
              v-for="category in story.attributes.categories"
              :key="category"
              color="secondary_lightest"
              class="mr-1 mb-1"
          >
            {{ category }}
          </v-chip>
        </v-card>
      </v-menu>
    </v-col>
    <v-col class="d-flex flex-row align-center py-2">
      <span v-if="!isShareTypeCommunity">
        <Avatar :src="story.publication.attributes.userAvatar"/>
        <span class="list-item__user-name pl-3">
          {{ story.publication.attributes.userName }}
        </span>
      </span>
      <span v-else>
        <Avatar :src="story.community.attributes.coverUrl"/>
        <span class="list-item__user-name pl-3">
          {{ story.community.attributes.name }}
        </span>
      </span>
      <span class="ml-auto mr-0 d-flex align-center align-self-end">
        <v-icon v-if="!isShareTypeCommunity">mdi-account</v-icon>
        <v-icon v-else>mdi-account-multiple-outline</v-icon>
      </span>
    </v-col>
  </v-row>
</template>
<script>
import Avatar from "../Elements/Avatar";

export default {
  components: { Avatar },
  props: {
    story: {
      type: Object,
      required: true
    }
  },
  data() {
    return {
      isDialogShown: false,
    }
  },
  computed: {
    storyImage () {
      return this.story.attributes.coverUrl ? this.story.attributes.coverUrl : this.imgPlaceholder
    },
    imgPlaceholder() {
      return require('../../assets/images/no_img.png');
    },
    isShareTypeCommunity() {
      return this.story.publication.attributes.shareType === 'community'
    },
    timePeriod() {
      const day = this.story.attributes.startDay
      const month = this.story.attributes.startMonth
      const year = this.story.attributes.startYear
      const endDay = this.story.attributes.endDay
      const endMonth = this.story.attributes.endMonth
      const endYear = this.story.attributes.endYear
      const startDate = this.$moment(`${year}-${month}-${day}`, 'YYYY-MMMM-DD').format('DD/MM/YYYY')
      if (day && month && year && endDay && endMonth && endYear) {
        const endDate = this.$moment(`${endYear}-${endMonth}-${endDay}`, 'YYYY-MMMM-DD').format('DD/MM/YYYY')
        return `${startDate} - ${endDate}`
      } else if (day && month && year) {
        return startDate
      } else {
        return '-'
      }
    },
  },
  methods: {
    goToStory() {
      this.$router.push({
        name: 'showStory',
        params: { id: this.story.publication.id }
      })
    },
  }
}
</script>
<style scoped lang="scss">
.list-item {
  background: $color-dark-white;
  border-radius: 5px;
  &__action {
    cursor: pointer;
  }
  &__img-wrapper {
    border-radius: 5px;
  }
  &__title {
    font-weight: bold;
    font-size: 14px;
    line-height: 180%;
    color: $color-tertiary;
    display: flex;
    align-items: center;
  }
  &__column-text {
    font-size: 12px;
    line-height: 14px;
    color: $color-tertiary;

    display: flex;
    align-items: center;
  }
  &__user-name {
    font-weight: bold;
    font-size: 12px;
    line-height: 180%;
    color: $color-tertiary;
    width: 140px;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }
}

</style>
