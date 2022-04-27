<template>
  <div class="people-collapse">
    <div
      :class="`people-collapse__header--${
        accent == 'purple' ? 'purple' : 'orange'
      }`"
      class="people-collapse__header d-flex align-center"
    >
      <h3 class="people-collapse__title">{{ title }}</h3>
      <span class="collapse-header__dot"></span>
      <span class="collapse-header__number">{{ collection.length }}</span>

      <!-- SHOW MORE BTN -->
      <button
        v-if="collection.length > showMoreLimit"
        class="collapse-header__show-btn ml-auto"
        :class="{
          'collapse-header__show-btn--expanded': expanded,
          'collapse-header__show-btn--purple': accent == 'purple',
          'collapse-header__show-btn--orange': accent == 'orange',
        }"
        @click="expanded = !expanded"
      >
        <span class="text-decoration-underline">
          {{
            $i18n.t(`mylives.my_people.${expanded ? "less_btn" : "all_btn"}`)
          }}</span>
        <v-icon :color="accent == 'purple' ? '#534898' : '#e75739'">
          mdi-chevron-down
        </v-icon>
      </button>
    </div>

    <div
      class="people-collapse__wrapper"
      :class="wrapperClass"
    >
      <slot :collection="collectionComputed"></slot>
    </div>
  </div>
</template>

<script>
import { take } from '@/utils/functions'

export default {
  name: 'PeopleCollapse',
  props: {
    accent: {
      type: String,
      default: 'purple',
    },
    wrapperClass: {
      type: String,
      default: '',
    },
    title: {
      type: String,
      default: '',
      required: true
    },
    collection: {
      type: Array,
      default: () => []
    },
    collectionLimit: {
      type: Number,
      default: 5
    },
    showMoreLimit: {
      type: Number,
      default: 5
    },
  },
  data() {
    return {
      expanded: false
    }
  },
  computed: {
    collectionComputed() {
      return this.expanded ? this.collection : take(this.collection, this.collectionLimit)
    }
  },
}
</script>

<style lang="scss">
.people-collapse {
  &__wrapper {
    padding-top: 12px;
  }

  &__header {
    display: flex;
    padding: 5px 20px 10px 20px;
    &--purple {
      background: $secondary-lightest;
    }
    &--orange {
      background: $primary-lightest;
    }
  }

  &__title {
    font-family: Enriqueta;
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    letter-spacing: -0.02em;
    color: $color-tertiary;
  }
  &__header--orange .collapse-header__dot {
    background: $color-primary;
  }
  &__header--orange .collapse-header__number {
    color: $color-primary;
  }
}

.collapse-header {
  &__dot {
    background: $secondary-darker;
    width: 5px;
    height: 5px;
    border-radius: 50%;
    margin-left: 16px;
    margin-right: 7px;
    margin-top: 6px;
  }

  &__number {
    font-family: Enriqueta;
    font-weight: 600;
    font-size: 20px;
    line-height: 27px;
    letter-spacing: -0.02em;

    color: $secondary-darker;
  }
  &__show-btn {
    font-family: Lato;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    @include transition();

    &--purple {
      color: $secondary-darker;
      &:hover {
        color: darken($secondary-darker, 20%);
      }
    }

    &--orange {
      color: $color-primary;
      &:hover {
        color: darken($color-primary, 20%);
      }
    }

    i {
      @include transition();
    }
    &--expanded i {
      transform: rotate(180deg);
    }
  }
}
</style>
