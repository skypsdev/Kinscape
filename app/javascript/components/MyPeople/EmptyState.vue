<template>
  <v-container class="d-flex flex-column justify-center mt-12">
    <v-img
      class="mb-12"
      height="320"
      contain
      :src="require('@/assets/images/my-people/empty-state')"
    />
    <h3 class="empty-state__title text-center mx-auto pb-0">
      {{ $i18n.t('mylives.my_people.empty_title') }}
    </h3>
    <p class="empty-state__text text-center mx-auto my-0 pt-0">
      {{$i18n.t('mylives.my_people.empty_text')}}
    </p>

    <div class="text-center">
      <v-btn
        class="empty-state__btn"
        text
        @click="showInviteModal"
      >
        <v-icon class="mr-2">mdi-plus-circle-outline</v-icon>
        {{ $i18n.t('mylives.my_people.empty_btn') }}
      </v-btn>
    </div>
  </v-container>
</template>
<script>
import {mapActions, mapState} from "vuex";

export default {
  computed: {
    ...mapState({
      community: state => state.families.community
    }),
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog'
    }),
    showInviteModal() {
      this.setDialog({
        title: this.$i18n.t('mylives.invitations.invite_dialog.title'),
        component: 'MyLifeInviteDialog',
        size: 'big',
      })
    },
  }
}
</script>
<style lang="scss">

.empty-state {
  &__title {
    font-family: Enriqueta;

    font-weight: bold;
    font-size: 32px;
    line-height: 43px;

    color: $tertiary;

    margin-bottom: 22px;
  }

  &__text {
    font-family: Enriqueta;
    font-size: 22px;
    line-height: 34px;

    color: $tertiary;
  }

  &__btn {
    margin-top: 52.5px;
    background: $color-secondary;
    border-radius: 24px;
    color: white !important;
    padding: 10.5px 22px !important;
    height: auto !important;
  }
}
</style>


