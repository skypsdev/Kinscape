<template>
  <div class="profile-edit">
    <div
        class="profile-edit__label mb-2"
        v-text="$i18n.t('placeholders.family.name')"
    />
    <v-text-field
        class="profile-edit__input"
        v-model="form.nickname"
        outlined
        hide-details
        single-line
        color="primary"
        type="text"
        @keydown="handleChange"
    />

    <v-row class="mt-2">
      <v-col>
        <p class="profile-details__label">
          <v-icon>mdi-email-outline</v-icon>
          {{ $i18n.t('users.user.email') }}
        </p>
        <p class="profile-details__info">
          {{ member.email }}
        </p>
      </v-col>
      <v-col>
        <p class="profile-details__label">
          <v-icon>mdi-home-outline</v-icon>
          {{ $i18n.t('users.user.address') }}
        </p>
        <p class="profile-details__info" v-for="address in member.profile.addresses" :key="address.name">
          {{ address.value }}
        </p>
      </v-col>
      <v-col>
        <p class="profile-details__label">
          <v-icon>mdi-phone-outline</v-icon>
          {{ $i18n.t('users.user.phone_number') }}
        </p>
        <p class="profile-details__info" v-for="number in member.profile.phoneNumbers" :key="number.name">
          {{ number.value }}
        </p>
      </v-col>
    </v-row>
    <v-row>
      <v-col class="d-flex flex-row align-center justify-end">
        <v-btn
            text
            color="primary"
            @click="showMore"
        >
          {{ $i18n.t('users.profile_page.show_more') }}
          <v-icon>mdi-chevron-right</v-icon>
        </v-btn>
      </v-col>
    </v-row>
  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import debounce from 'lodash/debounce'

export default {
  data: () => ({
    form: {
      nickname: '',
    }
  }),
  computed: {
    ...mapState({
      member: store => store.members.member
    })
  },
  mounted() {
    const { name, nickname } = this.member
    this.form.nickname = nickname || name
  },
  methods: {
    ...mapActions({
      updateMember: 'members/updateMember',
      setDialog: 'layout/setDialog'
    }),
    handleChange() {
      this.saveCommunityChanges(this)
    },
    showMore() {
      this.setDialog({
        title: this.$i18n.t('communities.member.edit.dialog.set_details'),
        component: 'EditMemberDialog',
        size: 'small'
      })
    },
    saveCommunityChanges: debounce((ctx) => {
      ctx.updateMember({
        id: ctx.member.id,
        form: {...ctx.form}
      })
    }, 700)
  }
}
</script>

<style lang="scss">
.profile-edit {
  &__label {
    font-family: Enriqueta;
    font-weight: bold;
    font-size: 18px;
    line-height: 24px;
    color: $tertiary;
  }
  &__input {
    &.v-text-field {
      font-size: 18px;
      color: $tertiary;
      .v-input__control {
        min-height: 48px !important;
      }
      .v-input__slot {
        min-height: 48px !important;
      }
      .v-label {
        top: 6px !important;
      }
      &--outlined fieldset {
        border-color: $medium-grey;
      }
    }
  }
}
.profile-details {
  &__heading {
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    letter-spacing: -0.02em;
    color: $tertiary;
  }
  &__label {
    font-weight: bold;
    font-size: 13px;
    line-height: 24px;
    color: $primary;
  }
  &__info {
    font-weight: bold;
    font-size: 16px;
    line-height: 19px;
    color: $tertiary;
  }
}
</style>

