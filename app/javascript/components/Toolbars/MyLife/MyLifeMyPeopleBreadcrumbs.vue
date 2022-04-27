<template>
  <Breadcrumbs :items="items" />
</template>

<script>
import { mapState } from 'vuex'
import Breadcrumbs from "@/components/Toolbars/Breadcrumbs";

export default {
  components: { Breadcrumbs },
  computed: {
    ...mapState({
      member: store => store.myPeoplePerson.member.member,
    }),

    items() {
      const items = [
        {
          label: 'My Life',
          icon: 'mdi-account-outline',
          to: { name: "myProfile" },
        },
        {
          label: "My People",
          to: { name: "myPeople" },
          icon: '',
        },
        {
          label: this.member.name,
          icon: ''
        },
      ]
      return items
    }
  }
}
</script>
