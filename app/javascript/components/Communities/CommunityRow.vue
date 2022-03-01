<template>
  <v-row class="list-item mb-2 list-item__action">
    <v-col
        class="pa-0 d-flex flex-row"
        cols="3"
        @click="goToCommunity"
    >
      <Avatar
          :src="community.attributes.cover_url"
          height="32"
          width="32"
          max-width="32"
          class="mx-3 my-auto"
      />
      <p class="list-item__title ma-0">{{ community.attributes.name }}</p>
    </v-col>
    <v-col class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ community.attributes.family_type }}
      </p>
    </v-col>
    <v-col class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ community.attributes.created_at ? this.$i18n.l('date.formats.default', community.attributes.created_at) : '-'  }}
      </p>
    </v-col>
    <v-col class="d-flex">
      <p class="list-item__column-text ma-0">
        {{ community.attributes.users_ids.length }}
      </p>
    </v-col>
    <v-col class="d-flex">
      <Avatar class="mr-2" :src="community.attributes.admin_avatar_url"/>
      <p class="list-item__column-text ma-0">
        {{ community.attributes.connector_name }}
      </p>
    </v-col>
  </v-row>
</template>

<script>
import Avatar from "../Elements/Avatar";

export default {
  components: { Avatar },
  props: {
    community: {
      type: Object,
      required: true
    },
  },
  methods: {
    goToCommunity() {
      this.$router.push({
          name: 'community',
          params: { id: this.community.id }
      })
    },
  }
}
</script>

<style scoped lang="scss">
.list-item {
  background: $color-dark-white;
  border-radius: 5px;
  &--invitation {
    cursor: auto;
  }
  &__action {
    cursor: pointer;
  }
  &__title {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;
  }
  &__column-text {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-style: normal;
    font-weight: normal;
    font-size: 13px;
    line-height: 16px;
  }
}

</style>
