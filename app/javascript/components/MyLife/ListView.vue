<template>
  <div>
    <v-row v-if="!isMobile" class="list-item list-item__head mb-4" no-gutters>
      <v-col
        cols="5"
        class="list-item__action list-item--invitation pl-4 pr-0 py-0 my-0"
      >
        <span
          class="list-item__title list-item__title--title-size"
          v-html="$i18n.t('mylives.invitations.name')"
        />
      </v-col>
      <v-col lg="2" class="list-item__action d-flex justify-start my-0">
        <span
          class="list-item__column-text"
          v-html="$i18n.t('mylives.invitations.date')"
        ></span>
      </v-col>
      <v-col cols="4" class="list-item__action d-flex justify-start pa-0 my-0">
        <span v-html="$i18n.t('mylives.invitations.actions')"></span>
      </v-col>
    </v-row>
    <div class="scroll" v-if="!isMobile">
      <v-row
        class="list-item list-item__row list-item__action mb-2"
        v-for="invitation in sentInvitations"
        :key="invitation.id"
        no-gutters
      >
        <v-col
          cols="5"
          class="list-item--invitation d-flex flex-row pl-4 pr-0 py-0 my-0"
        >
          <Avatar
            :src="require('../../assets/images/no_img.png')"
            height="32"
            width="32"
            max-width="32"
            class="mx-3 my-auto"
          />
          <p class="list-item__title ma-0">{{ invitation.attributes.email }}</p>
        </v-col>
        <v-col lg="2" class="d-flex justify-start my-0">
          <p class="list-item__column-text ma-0">
            {{
              $moment(invitation.attributes.created_at).format("Do MMM YYYY")
            }}
          </p>
        </v-col>
        <v-col
          cols="auto"
          class="v-list-item__action d-flex justify-start pa-0 my-0"
        >
          <div>
            <v-btn
              rounded
              outlined
              color="secondary"
              elevation="0"
              class="mr-2"
              height="30px"
              :fab="!isAboveLg"
              @click="resendInvitation(invitation)"
            >
              <v-icon size="24" class="icon_transform">mdi-refresh</v-icon>
              <span v-if="isAboveLg"
                >&nbsp;
                {{ $i18n.t("mylives.invitations.resend_invitation") }}</span
              >
            </v-btn>
            <v-btn
              rounded
              outlined
              color="secondary"
              elevation="0"
              height="30"
              @click="cancelInvitation(invitation)"
            >
              <v-icon size="24">mdi-close</v-icon
              ><span v-if="isAboveLg"
                >&nbsp;
                {{ $i18n.t("mylives.invitations.cancel_invitation") }}</span
              >
            </v-btn>
          </div>
        </v-col>
      </v-row>
    </div>
    <div class="mb-16" v-else>
      <v-row
        class="list-item list-item__row mb-2 list-item__action"
        v-for="invitation in sentInvitations"
        :key="invitation.id"
        no-gutters
      >
        <v-col class="pl-4 d-flex flex-row list-item--invitation py-3" cols="8">
          <Avatar class="mr-5 my-auto" />
          <div class="d-flex flex-column overflow-hidden">
            <p class="list-item__title mb-1">
              {{ invitation.attributes.email }}
            </p>
            <span class="list-item__column-text list-item__date-text">
              Invited:
              {{
                $moment(invitation.attributes.created_at).format("Do MMM YYYY")
              }}
            </span>
          </div>
        </v-col>
        <v-col class="v-list-item__action d-flex justify-end ma-0 mr-3">
          <div>
            <v-btn
              icon
              outlined
              color="secondary"
              elevation="0"
              class="mr-2"
              @click="resendInvitation(invitation)"
            >
              <v-icon class="icon_transform">mdi-refresh</v-icon>
            </v-btn>
            <v-btn
              icon
              outlined
              color="secondary"
              elevation="0"
              @click="cancelInvitation(invitation)"
            >
              <v-icon>mdi-close</v-icon>
            </v-btn>
          </div>
        </v-col>
      </v-row>
    </div>
  </div>
</template>
<script>
import Avatar from "../Elements/Avatar"
import breakpointsMixin from '../../mixins/breakpointsMixin'

export default {
  components: {
    Avatar
  },
  mixins: [
    breakpointsMixin
  ],
  props: {
    sentInvitations: {
      type: Array,
      required: true
    },
    resendInvitation: {
      type: Function,
      required: true
    },
    cancelInvitation: {
      type: Function,
      required: true
    }
  }
};
</script>
<style lang="scss">
.list-item {
  border-radius: 5px;
  &__head {
    font-family: $title-font !important;
    background: $color-light-grey;
    width: 100%;
    height: 32px;
  }
  &__row {
    background: $color-dark-white;
    width: 100%;
    height: 40px;
    @media #{map-get($display-breakpoints, 'md-and-down')} {
      height: 64px;
    }
  }
  &--invitation {
    cursor: auto;
  }
  &__action {
    cursor: pointer;
  }
  &__title {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;
  }
  &__column-text {
    color: $color-tertiary;
    display: flex;
    align-items: center;
    font-size: 1rem;
    @media #{map-get($display-breakpoints, 'md-and-down')} {
      font-style: normal;
      font-weight: normal;
      font-size: 9px;
      line-height: 11px;
      color: $color-text;
    }
  }
  &__date-text {
    font-size: 0.8rem;
  }
}
.icon_transform {
  transform: rotateY(180deg) rotate(-45deg);
}
.scroll {
  max-height: 232px;
  overflow-y: auto;
}
</style>
