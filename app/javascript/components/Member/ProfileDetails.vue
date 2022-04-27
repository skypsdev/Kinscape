<template>
  <section class="profile-details">
    <div>
      <h1 class="profile-details__heading ml-sm-2">
        {{ member.nickname || member.name }}
      </h1>
      <h2 class="profile-details__subheading mt-3 ml-sm-2">
        {{ member.community.name }} -  {{ $i18n.t(`families.member_roles.${member.role}`) }}
      </h2>
      <v-row class="mt-8 ml-sm-1">
        <v-col cols="12" md="4">
          <div v-if="member.email">
            <p class="profile-details__label">
              <v-icon color="#4B4B4B">mdi-email-outline</v-icon>
              {{ $i18n.t('users.user.email') }}
            </p>
            <p class="profile-details__info">
              {{ member.email }}
            </p>
          </div>
        </v-col>
        <v-col cols="12" md="4">
          <p v-if="member.profile.addresses.length > 0 && member.profile.addresses[0].value !== ''" class="profile-details__label">
            <v-icon color="#4B4B4B">mdi-home-outline</v-icon>
            {{ $i18n.t('users.user.address') }}
          </p>
          <span
              v-for="address in member.profile.addresses" :key="address.name"
          >
            <p v-if="address.value" class="profile-details__info">
              {{ address.value }}
            </p>
          </span>
        </v-col>
        <v-col cols="12" md="4">
          <p v-if="member.profile.phoneNumbers.length > 0 && member.profile.phoneNumbers[0].value !== ''" class="profile-details__label">
            <v-icon color="#4B4B4B">mdi-phone-outline</v-icon>
            {{ $i18n.t('users.user.phone_number') }}
          </p>
          <span v-for="number in member.profile.phoneNumbers" :key="number.name">
            <p v-if="number.value" class="profile-details__info">
              {{ number.value }}
            </p>
          </span>
        </v-col>
      </v-row>
      <v-row>
        <v-col class="d-flex flex-row align-center justify-start justify-md-end">
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
  </section>
</template>

<script>
import { mapActions, mapState } from 'vuex'

export default {
  computed: {
    ...mapState({
      member: store => store.members.member
    }),
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
    }),
    showMore() {
      this.setDialog({
        title: this.member.nickname || this.member.name,
        component: 'ShowMemberDialog',
        size: 'small'
      })
    },
  }
}
</script>
<style lang="scss" scoped>
.profile-details {
  &__heading {
    font-weight: bold;
    font-size: 40px;
    line-height: 54px;
    letter-spacing: -0.02em;
    color: $color-tertiary;
  }
  &__subheading {
    font-weight: 500;
    font-size: 19px;
    line-height: 25px;
    color: #868686;
  }
  &__label {
    font-weight: bold;
    font-size: 13px;
    line-height: 24px;
    color: $color-primary;
  }
  &__info {
    font-weight: bold;
    font-size: 16px;
    line-height: 19px;
    color: $color-tertiary;
  }
}
</style>
