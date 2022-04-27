<template>
  <Tooltip
    position="bottom right"
    name="profiles"
    :icons="['mdi-account-outline']"
    :title="$i18n.t('tooltips.profiles_title')"
    :description="$i18n.t('tooltips.profiles_description')"
  >
    <template #activator="{ attrs }">
      <div v-bind="attrs" class="mr-4">
        <Menu
          v-model="menuOpen"
          theme="toolbar"
          :items="families"
          :elevation="1"
          bottom
          @action="selectCommunity"
        >
          <template #activator="{ on, attrs }">
            <v-btn
              v-bind="attrs"
              v-on="on"
              class="select-profile__button"
              color="primary"
              elevation="0"
              large
              outlined
              rounded
            >
              {{ label }} <v-icon large>mdi-chevron-down</v-icon>
            </v-btn>
          </template>

          <template v-slot:item="{ item }">
            {{ item.attributes.name }}
          </template>
        </Menu>
      </div>
    </template>
  </Tooltip>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import Menu from '@/components/Menu/Menu'
import Tooltip from '@/components/Elements/Tooltip.vue'

export default {
  components: {
    Menu,
    Tooltip
  },
  props: {
    preselect: {
      type: String,
      required: false
    }
  },
  data: () => ({
    menuOpen: false
  }),
  computed: {
    ...mapState({
      families: (state) => state.core.user.personalPrivateFamilies
        .concat(state.families.simpleList.families),
    }),
    label () {
      if (this.preselect) {
        const selected = this.families.filter(
          (item) => item.id === this.preselect
        )
        return selected[0]?.attributes.name
      } else {
        return this.families[0]?.attributes.name
      }
    }
  },
  methods: {
    ...mapActions({
      forFamilyType: 'stories/forFamilyType'
    }),
    selectCommunity (item) {
      this.$emit('selected', item.id)
      this.$router.push({ query: { ...this.$route.query, community: item.id } })
      this.toggleMenuOpen()
    },
    toggleMenuOpen () {
      this.menuOpen = !this.menuOpen
    }
  }
}
</script>

<style lang="scss">
.select-profile {
  &__button.v-btn {
    max-width: 90%;

    .v-btn__content {
      font-size: 18px !important;
    }
  }
}
</style>
