<template>
  <div class="member-options">
    <Menu
      v-model="toggleOptions"
      :theme="theme"
      :items="memberOptions"
      :elevation="1"
      @toggleEditRole="toggleEditRole = !toggleEditRole"
      @toggleRemoveMember="toggleRemoveMember = !toggleRemoveMember"
      @toggleSetOffline="toggleSetOffline = !toggleSetOffline"
    >
      <template v-slot:activator="{ on, attrs }">
        <v-btn
          fab
          outlined
          x-small
          :color="theme === 'default' ? 'secondary' : 'primary'"
          elevation="0"
          v-bind="attrs"
          v-on="on"
        >
          <v-icon>mdi-dots-horizontal</v-icon>
        </v-btn>
      </template>
    </Menu>
    <v-dialog v-model="toggleEditRole" scrollable>
      <community-member-edit-role
        :member="member"
        @close="toggleEditRole = !toggleEditRole"
      />
    </v-dialog>
    <v-dialog v-model="toggleSetOffline" scrollable>
      <community-member-set-offline
        :member="member"
        @close="toggleSetOffline = !toggleSetOffline"
      />
    </v-dialog>
    <v-dialog v-model="toggleRemoveMember" scrollable>
      <community-member-remove
        :member="member"
        @close="toggleRemoveMember = !toggleRemoveMember"
      />
    </v-dialog>
  </div>
</template>
<script>
import Menu from '../../Menu/Menu'
import CommunityMemberEditRole from '../../Dialogs/CommunityMemberEditRole'
import CommunityMemberRemove from '../../Dialogs/CommunityMemberRemove'
import CommunityMemberSetOffline from '../../Dialogs/CommunityMemberSetOffline.vue'

export default {
  components: {
    Menu,
    CommunityMemberEditRole,
    CommunityMemberRemove,
    CommunityMemberSetOffline
  },
  props: {
    member: {
      type: Object,
      required: true
    },
    theme: {
      type: String,
      default: 'default',
      validator: (value) => ['default', 'toolbar', 'orange'].includes(value)
    }
  },
  data: () => ({
    toggleOptions: false,
    toggleEditRole: false,
    toggleRemoveMember: false,
    toggleSetOffline: false
  }),
  computed: {
    isOfflineMember() {
      return this.member.role === 'offline_member'
    },
    memberOptions() {
      return [
        ...(!this.isOfflineMember
          ? [
              {
                id: 'changeMemberRole',
                title: this.$i18n.t('families.member_options_change_role'),
                action: 'toggleEditRole'
              },
              {
                id: 'setOfflineMember',
                title: this.$i18n.t('families.member_options_set_offline'),
                action: 'toggleSetOffline'
              }
            ]
          : []),
        {
          id: 'removeMember',
          title: this.$i18n.t('families.member_options_remove'),
          action: 'toggleRemoveMember'
        }
      ]
    }
  }
}
</script>
