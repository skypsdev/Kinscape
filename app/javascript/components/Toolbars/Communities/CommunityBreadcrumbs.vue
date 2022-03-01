<template>
  <Breadcrumbs :items="items"/>
</template>

<script>
import { mapActions, mapState } from 'vuex'
import Breadcrumbs from "@/components/Toolbars/Breadcrumbs";

export default {
  components: { Breadcrumbs },
  props: {
    community: {
      type: Object,
    },
    memberName: {
      type: String,
      default: '',
    },
    isEditMode: {
      type: Boolean,
      default: false,
    },
  },
  computed: {
    ...mapState({
      families: state => state.families.simpleList.families,
      members: (state) => state.members.members,
      member: (state) => state.members.member,
    }),
    familyId() {
      return this.member.familyId
    },
    items() {
      const items = [
        {
          label: this.$i18n.t('header.families'),
          icon: 'mdi-account-multiple-outline',
          to: this.memberName && '/communities',
          list: !this.memberName && this.communities,
        },
        {
          label: this.communityName,
          icon: this.isEditMode ? 'mdi-pencil-outline' : '',
          list: this.memberName && this.filteredMembers,
        },
      ]
      if (this.memberName) {
        items.push({
          label: this.memberName,
          icon: this.isEditMode ? 'mdi-pencil-outline' : '',
        })
      }
      return items
    },
    communityName() {
      return this.community?.name || 'Community'
    },
    communities() {
      return this.families.map((family) => {
        return {
          ...family,
          attributes: {
            ...family.attributes,
          },
          title: family.attributes.name,
          routeName: 'showFamily',
        }
      })
    },
    filteredMembers() {
      return this.members.map((member) => {
        return {
          ...member,
          title: member.name,
          routeName: 'member',
        }
      })
    }
  },
  mounted() {
    if (this.memberName && !this.members.length) {
      this.loadMembersWithFilters()
    }
  },
  methods: {
    ...mapActions({
      loadMembers: 'members/loadNext',
      clearMembers: 'members/clearMembers',
    }),
    async loadMembersWithFilters() {
      this.clearMembers()
      let params = { page: 1 }
      let payload = {
        id: this.familyId,
        type: 'defaults'
      }
      await this.loadMembers(payload, params)
    },
  }
}
</script>
