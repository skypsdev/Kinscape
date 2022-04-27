<template>
  <div class="profile-card__group">
    <div class="profile-card__label">
      {{ ['birth_date', 'place_of_birth'].includes(item.name) ? '' : $i18n.t(`profile_card_types.${item.name}`) + ' - ' }}
      {{ group.title }}
    </div>
    <p
      class="profile-card__text mb-0"
      v-for="(line, index) in group.value"
      :key="`line-${index}`"
    >
      {{ line.value }}
    </p>
  </div>
</template>

<script>
export default {
  props: {
    index: {
      type: Number,
      required: true
    },
    item: {
      type: Object,
      required: true
    },
    group: {
      type: Object,
      required: true
    }
  }
};
</script>
