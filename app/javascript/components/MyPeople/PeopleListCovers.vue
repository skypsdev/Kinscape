<template>
  <div class="people-covers">
    <v-row>
      <v-col
        v-for="(person, index) in data"
        :key="person.name"
        :style="$vuetify.breakpoint.lgAndUp ? ' flex: 1 0 18%;' : ''"
        cols="6"
        md="3"
        sm="4"
      >
        <div
          class="people-covers__outer d-flex flex-column align-center"
          :class="index < 5 && 'mt-0'"
        >
          <VMenu
            :toggle="false"
            :items="[
              {
                title: $i18n.t('mylives.my_people.unfollow_btn'),
                action: 'unfollow',
              },
            ]"
            @unfollow="unfollow({ id: person.id, instance })"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                v-bind="attrs"
                class="covers-btn__options"
                v-on="on"
                icon
                outlined
                rounded
                color="#8B78FE"
                height="40"
                width="40"
              >
                <v-icon>mdi-dots-horizontal</v-icon>
              </v-btn>
            </template>
          </VMenu>
          <div class="d-flex justify-center people-covers__wrapper mt-auto">
            <router-link :to="generateLink(person)" class="text-decoration-none">
              <Avatar size="big" :src="person.attributes.avatarUrl" />
            </router-link>

            <!-- send btn -->
            <v-btn
              icon
              outlined
              rounded
              color="#8B78FE"
              height="40"
              width="40"
              class="covers-btn__send"
              @click="sendMessage(person.id, person.attributes.familyId)"
            >
              <v-icon>mdi-email-outline</v-icon>
            </v-btn>
          </div>
          <router-link :to="generateLink(person)" class="text-decoration-none">
            <div class="people-covers__title">
              {{ person.attributes.nickname }}
            </div>
          </router-link>
        </div>
      </v-col>
    </v-row>
  </div>
</template>

<script>

import VMenu from '@/components/Menu/Menu.vue'
import Avatar from '@/components/Elements/Avatar'
export default {
  name: "PeopleListCovers",
  components: { VMenu, Avatar },
  props: {
    instance: {
      type: String,
      default: '',
      required: true
    },
    data: {
      type: Array,
      default: () => [],
      required: true
    },
    sendMessage: {
      type: Function,
      default: () => null
    },
    unfollow: {
      type: Function,
      default: () => null
    },
    generateLink: {
      type: Function,
      default: () => null
    }
  }
}
</script>

<style lang="scss">
.people-covers {
  padding: 30px 20px 0;

  &__title {
    margin-top: 16px;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    /* or 133% */
    text-align: center;
    color: $tertiary;
  }

  &__outer {
    max-width: 208px;
    height: 240px;
    position: relative;
    margin-top: 69px;
  }
  &__wrapper {
    position: relative;
    width: 100%;
  }
}
.covers-btn {
  &__options {
    z-index: 1;
    position: absolute;
    top: 0;
    right: -14px;
  }
  &__send {
    position: absolute;
    bottom: -10px;
    right: -14px;
  }
}
</style>
