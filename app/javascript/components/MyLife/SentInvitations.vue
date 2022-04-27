<template>
  <PeopleCollapse
    :collection="finalInvitationList"
    :show-more-limit="Infinity"
    :collection-limit="Infinity"
    wrapper-class="py-0"
    :title="$i18n.t('mylives.invitations.sent_invitations')"
    accent="purple"
    class="mb-10 mt-3"
    #default="{ collection }"
  >
    <div class="pl-4 pr-6">
      <!-- top section -->
      <v-row class="mb-5 mt-3">
        <v-col
          cols="12"
          md="4"
          v-if="!isMobile"
          class="d-flex align-center"
        >
          <Search
            class="members__search"
            :search-term="search"
            :placeholder="'Search People'"
            :theme="'secondary'"
            @setSearch="search = $event.query"
          />
        </v-col>

        <v-col
          cols="12"
          md="8"
        >
          <v-btn
            outlined
            rounded
            depressed
            color="secondary"
            class="form-button mr-3"
            @click="showInviteDialog"
          >
            <v-icon
              size="20"
              class="mr-2"
              color="secondary"
            >
              mdi-plus-circle-outline
            </v-icon>
            {{ $i18n.t("mylives.invitations.invite_people") }}
          </v-btn>
          <BaseMenu
            v-if="collection.length"
            :items="staticData.invitationsMenuOptions"
            :toggle="false"
            :elevation="1"
            @cancelInvitations="cancelAllInvitations"
            @resendInvitations="resendAllInvitations"
          >
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                v-bind="attrs"
                v-on="on"
                fab
                outlined
                small
                :color="'secondary'"
                elevation="0"
              >
                <v-icon> mdi-dots-horizontal </v-icon>
              </v-btn>
            </template>
          </BaseMenu>
        </v-col>
      </v-row>

      <!-- lists -->
      <template v-if="finalInvitationList.length > 0">
        <ListView
          v-if="isList"
          :sentInvitations="collection"
          :resendInvitation="resendInvitation"
          :cancelInvitation="cancelInvitation"
        />
        <GridView
          v-else
          :sentInvitations="collection"
          :resendInvitation="resendInvitation"
          :cancelInvitation="cancelInvitation"
        />
      </template>

      <EmptyState
        v-else
        :invite-fn="showInviteDialog"
        :is-page-visited="isPageVisited"
      />
    </div>
  </PeopleCollapse>
</template>
<script>
import { mapActions, mapState } from "vuex"

import PeopleCollapse from "@/components/MyPeople/PeopleCollapse"
import GridView from "@/components/MyLife/GridView"
import ListView from "@/components/MyLife/ListView"
import Search from "@/components/Elements/Forms/Search"
import EmptyState from "@/components/MyLife/Invitations/EmptyState"
import BaseMenu from '@/components/Menu/Menu.vue'
import breakpointsMixin from "@/mixins/breakpointsMixin"

export default {
  components: {
    PeopleCollapse,
    EmptyState,
    GridView,
    ListView,
    Search,
    BaseMenu,
  },
  mixins: [
    breakpointsMixin
  ],
  props: {
    isPageVisited: {
      type: Boolean,
      required: true
    }
  },
  data() {
    return {
      search: '',
      staticData: {
        invitationsMenuOptions: [
          {
            id: 'resend_all_invitation',
            title: this.$i18n.t('mylives.invitations.resend_all_invitation'),
            action: 'resendInvitations'
          },
          {
            id: 'cancel_all_invitation',
            title: this.$i18n.t('mylives.invitations.cancel_all_invitation'),
            action: 'cancelInvitations'
          }
        ]
      }
    };
  },
  computed: {
    ...mapState('invitations', [
      'viewType',
      'sentInvitations'
    ]),
    isList() {
      return this.viewType !== 'grid'
    },
    finalInvitationList() {
      return this.sentInvitations.filter((member) => {
        const query = this.search.toLowerCase()
        return member.attributes.email.toLowerCase().includes(query)
      })
    }
  },
  methods: {
    ...mapActions({
      resendInvitations: 'invitations/resendInvitations',
      cancelInvitations: 'invitations/cancelInvitations',
      setDialog: 'layout/setDialog',
      setSnackbar: 'layout/setSnackbar',
    }),
    resendInvitation(invitation) {
      this.resendInvitations({ invitationIds: [invitation.id] })
    },
    async resendAllInvitations() {
      this.resendInvitations({ invitationIds: [this.sentInvitations.map(el => el.attributes.family_id)] })
    },
    cancelInvitation(invitation) {
      this.cancelInvitations([invitation.id])
    },
    cancelAllInvitations() {
      this.cancelInvitations(this.sentInvitations.map(el => el.id))
    },
    showInviteDialog() {
      this.setDialog({
        title: this.$i18n.t('mylives.invitations.invite_dialog.title'),
        component: 'MyLifeInviteDialog',
        size: 'big',
      })
    },
  }
};
</script>
<style lang="scss" scoped>
.members {
  &__search {
    min-width: 260px;
  }
}
.form-button {
  padding: 0 25px 0 25px !important;
}
</style>
