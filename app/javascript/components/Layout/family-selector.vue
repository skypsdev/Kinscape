<template>
  <div class="submenu__select-wrapper">
    <select
      id="family-filter"
      class="submenu__select"
      :disabled="isLoading"
      @change="selectFamily"
    >
      <option
        v-if="!onlyShowConcreteCommunities"
        value="draft"
        :selected="selected === 'draft'"
        @change="selectFamily"
      >
        Private Stories
      </option>
      <option
        v-if="!onlyShowConcreteCommunities"
        value="all"
        :selected="selected === 'all'"
        @change="selectFamily"
      >
        All Stories
      </option>
      <option
        v-for="family in families"
        :key="family.id"
        :value="family.id"
        :selected="family.id === selected"
        @change="selectFamily"
      >
        {{ family.attributes.name }}
      </option>
    </select>
  </div>
</template>

<script>
import { mapActions, mapGetters, mapState } from 'vuex'

// TODO: refactoring required: i18n + remove $emit & unused props

export default {
  props: {
    onlyShowConcreteCommunities: {
      type: Boolean,
      required: false,
      default: true
    },
    defaultId: {
      type: [Number, String],
      required: false,
      default: null
    }
  },
  data () {
    return {
      selected: ''
    }
  },
  computed: {
    ...mapState({
      families: state => state.families.simpleList.families,
      currentUser: state => state.core.user
    }),
    ...mapGetters({
      isLoading: 'stories/isLoading',
      loadFamily: 'stories/all',
      getFamilyType: 'stories/getFamilyType'
    })
  },
  mounted () {
    // TODO-SELECTED-FAMILY-ID: use correct family id
    this.selected = this.defaultId !== null ? this.defaultId : this.families.first.id
  },
  methods: {
    ...mapActions({
      forFamilyType: 'stories/forFamilyType'
    }),
    selectFamily (event) {
      const newFamilyId = event.target.value
      if (this.selected !== newFamilyId) {
        this.selected = newFamilyId
        if (newFamilyId !== 'all' && newFamilyId !== 'draft') {
          this.forFamilyType('')
        }
        this.$emit('family-changed', newFamilyId)
      }
    }
  }
}
</script>
