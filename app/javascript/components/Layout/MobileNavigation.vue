<template>
  <div>
    <v-list-item href="/account">
      <v-list-item-content>
        <v-list-item-title class="text-h6">
          {{ currentUser.name }}
        </v-list-item-title>
        <v-list-item-subtitle>
          {{ currentUser.email }}
        </v-list-item-subtitle>
      </v-list-item-content>
    </v-list-item>
    
    <v-divider></v-divider>
    
    <v-list nav dense>
      <v-list-item to="/communities">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('header.families') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item to="/stories">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('header.stories') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item to="/mylife/profile">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('header.mylife') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item @click="openNewStoryDialog">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('stories.new') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item to="">
        <v-list-item-content>
          <v-list-item-title>Message</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item href="/account">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('user_menu.account') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item href="/subscriptions">
        <v-list-item-content>
          <v-list-item-title class="pr-2 new-paying-member-cvr-btn">{{ $i18n.t('user_menu.manage_subscription') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>

      <v-list-item link target="_blank" href="https://intercom.help/kinscape">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('user_menu.help_center') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
  
      <v-list-item href="/sign_out">
        <v-list-item-content>
          <v-list-item-title>{{ $i18n.t('user_menu.sign_out') }}</v-list-item-title>
        </v-list-item-content>
      </v-list-item>
    </v-list>
  </div>
  
</template>

<script>
import {mapActions, mapState} from 'vuex'

export default {
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    })
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    openNewStoryDialog() {
      this.setDialog({
        component: 'NewStoryFormDialog',
        title: this.$i18n.t('stories.newStoryDialog.title'),
        size: 'big'
      })
    }
  }
}
</script>

<style scoped>
</style>
