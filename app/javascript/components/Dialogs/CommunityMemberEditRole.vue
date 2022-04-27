<template>
  <DialogContent
    class="edit-role"
    :title="$i18n.t('families.dialog_change_role.title')"
    @close="$emit('close')"
  >
    <template v-slot:content>
      <v-container class="pt-8">
        <h4 class="dialog-content__title">
          {{ $i18n.t('families.dialog_change_role.content_title') }}
        </h4>
        <p class="dialog-content__text">
          {{
            $i18n.t('families.dialog_change_role.content_text', {
              name: member.name
            })
          }}
          <a
            href="/"
            :title="
              $i18n.t('families.dialog_change_role.content_learn_more_title')
            "
            >{{
              $i18n.t('families.dialog_change_role.content_learn_more_label')
            }}</a
          >
        </p>
        <div class="mt-4 mx-md-6 pa-lg-4">
          <v-card
            class="member-card pa-4 px-sm-8 py-sm-5 d-flex flex-column flex-sm-row justify-sm-space-between"
            elevation="0"
          >
            <div class="member-card__avatar d-flex align-center mb-2 mb-sm-0">
              <Avatar class="mr-4" :src="member.avatarUrl" size="medium" />
              <h4 class="member-card__name">{{ member.name }}</h4>
            </div>
            <div class="member-card__role d-flex align-center">
              <Menu
                v-model="roleOptionsOpen"
                theme="orange"
                :items="availableRoles"
                @setRole="(option) => setRole(option)"
              >
                <template v-slot:activator="{ on, attrs }">
                  <v-btn
                    :class="{
                      'member-card__role-dropdown': true,
                      'member-card__role-dropdown--selected': !!newRoleLabel
                    }"
                    color="primary"
                    elevation="0"
                    v-bind="attrs"
                    v-on="on"
                    rounded
                    outlined
                  >
                    {{
                      newRoleLabel
                        ? newRoleLabel
                        : $i18n.t('families.dialog_change_role.dropdown_label')
                    }}
                    <v-icon right>
                      {{ `mdi-chevron-${roleOptionsOpen ? 'up' : 'down'}` }}
                    </v-icon>
                  </v-btn>
                </template>
              </Menu>
            </div>
          </v-card>
        </div>
      </v-container>
      <v-snackbar v-model="error" color="error" outlined rounded>
        {{ errorText }}
        <template v-slot:action="{ attrs }">
          <v-btn color="blue" text v-bind="attrs" @click="error = false">
            Close
          </v-btn>
        </template>
      </v-snackbar>
    </template>
    <template v-slot:actions>
      <v-btn
        :class="['px-8 mb-4', { 'v-btn--active': !!newRoleLabel }]"
        color="primary"
        elevation="0"
        :disabled="!newRoleLabel"
        x-large
        rounded
        outlined
        @click="closeDialog"
      >
        {{ $i18n.t('families.dialog_change_role.actions.confirm') }}
      </v-btn>
    </template>
  </DialogContent>
</template>

<script>
import { updateRole } from '../../repositories/kinships-repository'
import DialogContent from '../Layout/Dialog/DialogContent'
import Avatar from '../Elements/Avatar'
import Menu from '../Menu/Menu'

import { mapActions } from 'vuex'

export default {
  components: {
    DialogContent,
    Avatar,
    Menu
  },
  props: {
    member: { type: Object, required: true }
  },
  data: () => ({
    confirm: false,
    newRoleLabel: null,
    roleOptionsOpen: false,
    error: false,
    errorText: ''
  }),
  computed: {
    availableRoles() {
      return [
        {
          id: 'member',
          title: this.$i18n.t('families.member_roles.member'),
          action: 'setRole'
        },
        {
          id: 'guest',
          title: this.$i18n.t('families.member_roles.guest'),
          action: 'setRole'
        },
        {
          id: 'co_admin',
          title: this.$i18n.t('families.member_roles.co_admin'),
          action: 'setRole'
        }
      ]
    }
  },
  mounted () {
    this.newRoleLabel = this.$i18n.t(`families.member_roles.${this.member.role}`)
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError'
    }),
    async setRole(role) {
      const { id } = this.member

      await updateRole(id, {
        kinship: {
          role: role.id
        }
      })
        .then(() => {
          this.newRoleLabel = role.title
        })
        .catch((error) => {
          this.setError(error)
        })
    },
    closeDialog () {
      this.$emit('close')
      this.$router.go()
    }
  }
}
</script>

<style lang="scss">
.member-card {
  background: $color-dark-white !important;

  &__name {
    color: $color-tertiary;
    font-family: Lato;
    font-size: 17px;
    line-height: 24px;
  }

  &__role {
    &-dropdown {
      background: #fff;
      font-size: 16px;

      &--selected {
        background: $color-primary;

        .v-btn__content {
          color: #fff;
        }
      }
    }

    &-value {
      color: $color-grey;
      font-size: 12px;
      font-weight: bold;
      margin-right: 20px;
    }
  }

  .v-btn:not(.v-btn--round).v-btn--outlined {
    padding: 0 24px;
  }
}

.edit-role {
  width: 80vw;

  .v-card__actions > .v-btn.v-btn {
    padding: 0 24px;

    &.v-size--x-large {
      font-size: 18px;
    }
  }
}
</style>
