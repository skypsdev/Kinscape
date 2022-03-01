<template>
  <TabSwitch :buttons="menuButtons" :simulate-path="hasSimulatedPath? 'MyVault': ''" />
</template>

<script>
import TabSwitch from '../../Elements/TabSwitch'

export default {
  components: { TabSwitch },
    props:{
      hasSimulatedPath: {
        type:Boolean,
        default:false
      }
  },
  computed: {
    menuButtons() {
      return [
        {
          label: 'mylives.submenu.profile',
          title: 'mylives.submenu.profile_title',
          to: {name: 'myProfile'}
        },
        {
          label: 'mylives.submenu.my_vault',
          title: 'mylives.submenu.my_vault_title',
          to: { name: 'MyVault' }
        }
      ]
    }
  }
}
</script>
