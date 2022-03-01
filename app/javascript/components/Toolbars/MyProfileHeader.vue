<template>
  <v-row>
    <v-col class="d-flex flex-row align-center">
      <SelectMyProfileCommunity />
      <BackToCommunity />
      <v-spacer/>
    </v-col>
    <v-col>
      <MyLifeMenu />
    </v-col>
    <v-col></v-col>
  </v-row>
</template>

<script>
import MyLifeMenu from './MyLife/MyLifeMenu'
import SelectMyProfileCommunity from './MyLife/SelectMyProfileCommunity'
import BackToCommunity from './MyLife/BackToCommunity'

export default {
  components: {
    SelectMyProfileCommunity,
    BackToCommunity,
    MyLifeMenu
  }
}
</script>
