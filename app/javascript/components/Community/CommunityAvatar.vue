<template>
  <BaseAvatar :src="cover" contain rounded size="biggest" />
</template>

<script>
import { mapState } from 'vuex'
import BaseAvatar from '@/components/Elements/Avatar.vue'

export default {
  components: { BaseAvatar },
  computed: mapState({
    cover: state => state.families.community?.content?.cover
  })
}
</script>