<template>
  <v-avatar
    v-bind="$attrs"
    :size="avatarSize"
    :min-height="avatarSize"
    :min-width="avatarSize"
    class="simple-avatar"
    :class="outlined ? 'simple-avatar--outlined' : ''"
  >
    <v-img v-if="src" :contain="'contain' in $attrs" :src="src" />
    <v-icon v-else :size="iconFontSize" color="#939393">
      {{ icon }}
    </v-icon>
  </v-avatar>
</template>

<script>
export default {
  props: {
    src: {
      type: String,
      default: ''
    },
    icon: {
      type: String,
      default: 'mdi-account-outline'
    },
    size: {
      type: String,
      default: 'default'
    },
    outlined: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    avatarSize() {
      const sizes = {
        biggest: 208,
        big: 168,
        medium: 50,
        default: 32,
        small: 22
      }
      return sizes?.[this.size] ?? this.size
    },
    iconFontSize() {
      const sizes = {
        small: 4,
        default: 24,
        medium: 38,
        big: 68,
        biggest: 128,
      }

      return sizes?.[this.size] ?? this.size
    }
  }
}
</script>

<style lang="scss" scoped>
.simple-avatar {
  background-color: #e6e6e6;
  &--outlined {
    border: 3px solid #a293fe;
  }
}
</style>
