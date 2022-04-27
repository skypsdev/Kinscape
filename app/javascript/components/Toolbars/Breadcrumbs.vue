<template>
  <div class="breadcrumbs d-none d-sm-flex pl-0">
    <div
      v-for="(item, index) in sortedItems"
      :key="index"
      class="d-flex flex-row"
    >
      <v-menu
        v-if="item.list"
        class="breadcrumbs__menu"
        bottom
        offset-y
        max-height="80vh"
        max-width="300px"
      >
        <template v-slot:activator="{ on, attrs }">
          <v-btn
            plain
            x-small
            class="breadcrumbs__item"
            :class="isLastItem(index) && 'breadcrumbs__item--last'"
            v-bind="attrs"
            v-on="on"
          >
            <v-icon class="mr-1">{{ item.icon }}</v-icon>
            {{ item.label }}
          </v-btn>
        </template>
        <v-card>
          <v-list dense>
            <v-list-item
              v-for="listItem in item.list"
              :key="listItem.id"
              :to="{
                name: listItem.routeName || $route.name,
                params: { id: listItem.id }
              }"
            >
              <v-list-item-content>
                <v-list-item-title class="pr-2">{{
                  listItem.title
                }}</v-list-item-title>
              </v-list-item-content>
            </v-list-item>
          </v-list>
        </v-card>
      </v-menu>
      <v-btn
        v-else
        plain
        x-small
        class="breadcrumbs__item d-flex pl-0"
        :class="isLastItem(index) && 'breadcrumbs__item--last'"
        :to="item.to"
      >
        <v-icon class="mr-1">{{ item.icon }}</v-icon>
        {{ item.label }}
      </v-btn>
      <v-icon v-if="!isLastItem(index)" small>mdi-chevron-right</v-icon>
    </div>
  </div>
</template>
<script>
import { cloneDeep } from 'lodash'

export default {
  props: {
    items: {
      type: Array,
      default: () => []
    }
  },
  computed: {
    sortedItems() {
      return cloneDeep(this.items).map((item) => {
        if (item.list) {
          item.list.sort((a, b) => {
            if (a.title < b.title) {
              return -1
            }

            if (a.title > b.title) {
              return 1
            }

            return 0
          })
        }

        return item
      })
    }
  },
  methods: {
    isLastItem(index) {
      return this.items.length === index + 1
    }
  }
}
</script>
<style lang="scss" scoped>
.breadcrumbs {
  height: 24px;
  ::v-deep .v-btn__content {
    font-size: 14px;
    font-weight: 400;
    letter-spacing: normal;
    .v-icon {
      font-size: 16px;
    }
  }
  &__item {
    ::v-deep .v-btn__content {
      font-family: Enriqueta;
      font-style: normal;
      font-weight: 600;
      font-size: 14px;
      line-height: 25px;
    }
    &--last {
      color: $color-primary;
    }
  }
}
</style>
<style lang="scss">
.v-menu__content {
  overscroll-behavior: none;
}
</style>
