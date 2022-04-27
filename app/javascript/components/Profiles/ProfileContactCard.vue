<template>
  <v-card
    :class="{ 'profile-card': true, 'profile-card--large': largeCard }"
    elevation="0"
    ref="root"
  >
    <v-icon size="18" class="profile-card__icon" color="primary">{{
      item.icon
    }}</v-icon>

    <template v-if="item.value.length > 1">
      <span
        :class="{
          'profile-card__options': true,
          'profile-card__options--expanded': expanded
        }"
        @click="expand"
        >({{ item.value.length }})</span
      >
    </template>

    <template v-for="(group, index) in item.value">
      <template v-if="!expanded">
        <template v-if="index < 1">
          <ProfileGroupCard :index="index" :item="item" :group="group" :key="`value-${index}`" />
        </template>
      </template>
      <template v-else>
        <ProfileGroupCard :index="index" :item="item" :group="group" :key="`value-${index}`" />
      </template>
    </template>
  </v-card>
</template>

<script>
import ProfileGroupCard from './ProfileGroupCard'
export default {
  components: {
    ProfileGroupCard
  },
  props: {
    item: { type: Object, required: true },
    expanded: { type: Boolean, default: false }
  },
  computed: {
    largeCard() {
      return ['addresses'].includes(this.item.name)
    }
  },
  watch: {
    expanded() {
      this.setHeight()
    }
  },
  mounted() {
    this.setHeight()
  },
  methods: {
    setHeight() {
      const element = this.$refs.root.$el
      if (element.offsetHeight > 140) {
        this.$emit('changeDisplayMoreBtn', true)
      }
      element.style.height = 'auto'
    },
    expand() {
      this.$emit('expand', !this.expanded)
      this.setHeight()
    }
  }
}
</script>

<style lang="scss">
.profile-card {
  background: white;
  border-radius: 5px;
  min-height: 56px;
  position: relative;
  max-width: 313px;
  transform: max-height 250ms ease-out;

  &--large {
    min-height: 128px;
  }

  &__group {
    padding: 10px 10px 10px 38px;
    position: relative;

    &:after {
      background: rgba($color-medium-grey, 0.5);
      bottom: 0;
      content: '';
      display: block;
      height: 1px;
      left: 0;
      position: absolute;
      width: 92%;
      @include center-absolute-x;
    }

    &:last-of-type {
      border-bottom: 0;

      &:after {
        display: none;
      }
    }
  }

  &__label {
    color: $color-primary;
    font-size: 13px !important;
    font-weight: bold;
    margin: 0;
  }

  &__text {
    color: $color-text;
    font-size: 16px !important;
    font-weight: bold;
    line-height: 1.22rem;
    margin-bottom: 0;
  }

  &__icon.v-icon {
    left: 10px;
    position: absolute;
    top: 10px;
    width: 15px;
  }

  &__options {
    align-items: center;
    color: $color-primary;
    cursor: pointer;
    display: flex;
    font-size: 13px;
    padding-right: 10px;
    position: absolute;
    justify-content: center;
    top: 10px;
    right: 10px;
    z-index: 1;

    &:after {
      @include pseudo($width: 0, $height: 0);
      border-style: solid;
      border-color: $color-primary transparent transparent transparent;
      border-width: 5px 4px 0 4px;
      right: 0;
      transition: transform 250ms ease-out;
      transform-origin: center;
    }

    &--expanded {
      &:after {
        transform: rotate(180deg);
      }
    }
  }
}
</style>
