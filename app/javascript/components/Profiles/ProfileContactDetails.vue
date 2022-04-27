<template>
  <v-card
    :class="{
      'contact-details': true,
      'contact-details--empty': !cards.length,
    }"
    elevation="0"
    rounded="lg"
    v-if="cards.length || editable"
  >
    <div class="contact-details__header d-md-flex justify-md-space-between">
      <h2 class="contact-details__title">
        {{ $i18n.t("profile.cards.title") }}
      </h2>
      <v-btn
        v-if="editable"
        class="contact-details__edit"
        @click="() => (editDialog = true)"
        color="primary"
        elevation="0"
        plain
        x-small
      >
        <v-icon class="mr-2" small>mdi-pencil</v-icon>
        {{ $i18n.t("profile.cards.edit_button") }}
      </v-btn>
    </div>

    <div class="profile-attributes mt-4" v-if="cards.length">
      <div
        :class="{
          'profile-attributes__window': true,
          'profile-attributes__window--expanded': expanded,
        }"
        :data-items="cards.length"
      >
        <div class="profile-attributes__grid">
          <vuuri
            ref="vuuri"
            class="vuuri-container"
            v-model="cards"
            item-key="id"
            :get-item-width="getItemWidth"
            :get-item-height="getItemHeight"
          >
            <template #item="{ item }">
              <ProfileContactCard
                class="profile-attributes__card"
                :expanded="expanded"
                :item="item"
                @expand="expand"
                @changeDisplayMoreBtn="changeDisplayMoreBtn"
              />
            </template>
          </vuuri>
        </div>
      </div>
      <div
        :class="
          displayMoreBtn || cards.length > 5
            ? 'profile-attributes__footer pa-3'
            : 'pa-3'
        "
      >
        <v-btn
          plain
          color="primary"
          @click="expand"
          v-if="displayMoreBtn || cards.length > 5"
        >
          {{
            expanded
              ? $i18n.t("profile.cards.show_less")
              : $i18n.t("profile.cards.show_more")
          }}
          <v-icon
            :class="{
              'profile-attributes__footer-icon': true,
              'profile-attributes__footer-icon--expanded': expanded,
            }"
            >mdi-chevron-down</v-icon
          >
        </v-btn>
      </div>
    </div>

    <v-dialog
      v-if="editable"
      content-class="dialog-full-width"
      v-model="editDialog"
      scrollable
    >
      <EditProfileContactDetails
        v-if="form"
        :toggle="editDialog"
        :items="editableCards"
        :value="form.form.profileAttrs"
        :order="form.form.profileAttrs.profileAttrsOrder"
        @close="editDialog = !editDialog"
        @submit="submit"
      />
    </v-dialog>
  </v-card>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'
import { cloneDeep as _cloneDeep } from 'lodash'
import vuuri from 'vuuri'
import EditProfileContactDetails from '../Dialogs/EditProfileContactDetails'
import ProfileContactCard from '../Profiles/ProfileContactCard'
import { without } from '@/utils/functions'

export default {
  components: {
    vuuri,
    EditProfileContactDetails,
    ProfileContactCard
  },
  props: {
    attributes: {
      type: Object,
      required: true
    },
    kinshipId: {
      type: String,
      required: true
    },
    editable: {
      type: Boolean,
      default: false
    }
  },
  data() {
    return {
      expanded: false,
      editDialog: false,
      displayMoreBtn: false,
      form: null,
      profileAttrs: {},
      cards: [],
      editableCards: [],
      defaultItems: {
        emails: {
          id: 0,
          title: this.$i18n.t('profile_card_types.emails'),
          label: this.$i18n.t('location_types.home'),
          icon: 'mdi-email-outline',
          name: 'emails',
          value: []
        },
        addresses: {
          id: 1,
          title: this.$i18n.t('profile_card_types.addresses'),
          label: this.$i18n.t('location_types.home'),
          icon: 'mdi-home-outline',
          name: 'addresses',
          value: []
        },
        websites: {
          id: 2,
          title: this.$i18n.t('profile_card_types.websites'),
          label: this.$i18n.t('website_types.personal'),
          icon: 'mdi-web',
          name: 'websites',
          value: []
        },
        socials: {
          id: 3,
          title: this.$i18n.t('profile_card_types.socials'),
          label: this.$i18n.t('social_types.facebook'),
          icon: 'mdi-account-outline',
          name: 'socials',
          value: []
        },
        birthDate: {
          id: 4,
          title: this.$i18n.t('profile_card_types.birth_date'),
          label: this.$i18n.t('date_types.birth_date'),
          icon: 'mdi-calendar',
          name: 'birth_date',
          type: 'date',
          value: []
        },
        phoneNumbers: {
          id: 5,
          title: this.$i18n.t('profile_card_types.phone_numbers'),
          label: this.$i18n.t('phone_types.mobile'),
          icon: 'mdi-phone-outline',
          name: 'phone_numbers',
          value: []
        },
        placeOfBirth: {
          id: 7,
          title: this.$i18n.t('profile_card_types.place_of_birth'),
          label: this.$i18n.t('profile_card_types.place_of_birth'),
          icon: 'mdi-map-marker-outline',
          name: 'place_of_birth',
          value: []
        },
        relationships: {
          id: 8,
          title: this.$i18n.t('profile_card_types.relationships'),
          label: this.$i18n.t('relationships.mother'),
          icon: 'mdi-account-multiple-outline',
          name: 'relationships',
          value: []
        },
        locations: {
          id: 9,
          title: this.$i18n.t('profile_card_types.locations'),
          label: this.$i18n.t('location_types.current_location'),
          icon: 'mdi-crosshairs-gps',
          name: 'locations',
          value: []
        },
        custom: {
          id: 10,
          title: this.$i18n.t('profile_card_types.custom'),
          label: this.$i18n.t('profile_card_types.custom'),
          icon: 'mdi-account-outline',
          name: 'custom'
        },
        customDate: {
          id: 11,
          title: this.$i18n.t('profile_card_types.custom_date'),
          label: this.$i18n.t('profile_card_types.custom_date'),
          icon: 'mdi-calendar',
          name: 'custom_date'
        }
      }
    }
  },
  computed: {
    ...mapGetters({
      kinships: 'kinships/all'
    })
  },
  created() {
    this.profileAttrs = _cloneDeep(this.attributes)

    this.form = {
      id: this.kinshipId,
      form: {
        profileAttrs: this.profileAttrs
      }
    }

    const { profileAttrsOrder } = this.profileAttrs

    const sortByOrder = (a, b) => {
      return (
        profileAttrsOrder.indexOf(a.id) - profileAttrsOrder.indexOf(b.id)
      )
    }

    const createCard = (key) => {
      const defaultItem = this.defaultItems[key]
      const profileItem = this.profileAttrs[key]

      const { id, name, icon, label, title, type } = defaultItem
      const item = {
        id,
        name,
        icon,
        label,
        title,
        type
      }

      if (profileItem && profileItem[0].value) {
        item.value = profileItem
      } else {
        item.value = defaultItem?.value ? defaultItem.value : []
      }

      return item
    }

    this.editableCards = Object.keys(this.defaultItems)
      .map(createCard)
      .filter((item) => {
        if (item.name === 'custom' && !item.value.length) return false
        if (item.name === 'custom_date' && !item.value.length) return false
        return true
      })

    this.cards =
      without(Object.keys(this.profileAttrs), "profileAttrsOrder", "profile_attrs_order")
        .map(createCard)

    if (profileAttrsOrder) {
      this.cards.sort(sortByOrder)
      this.editableCards.sort(sortByOrder)
    }
  },
  methods: {
    ...mapActions({
      updateMember: 'members/updateMember'
    }),
    async submit(attributes) {
      const payload = {
        id: this.form.id,
        form: {
          profileAttrs: attributes
        }
      }

      try {
        await this.updateMember(payload)
      } catch (error) {
        console.error(error)
      } finally {
        this.editDialog = false
        this.$router.go()
      }
    },
    expand() {
      this.expanded = !this.expanded
      this.$nextTick(() => {
        this.$refs.vuuri.update()
      })
    },
    changeDisplayMoreBtn() {
      this.displayMoreBtn = true
    },
    getItemWidth() {
      return '31%'
    },
    getItemHeight() {
      return 'auto'
    }
  }
}
</script>

<style lang="scss">
.contact-details {
  background: $color-dark-white !important;
  padding: 18px 24px 0 24px;
  width: 848px;

  &--empty {
    padding-bottom: 18px;
  }

  &__title {
    color: $color-tertiary;
    font-size: 18px;
    line-height: 1rem;
  }
}

.profile-attributes {
  &__grid {
    margin: -5px;
  }

  &__window {
    margin-bottom: 12px;
    max-height: 140px;
    overflow: hidden;
    transition: max-height 250ms ease-out;

    @media #{map-get($display-breakpoints, 'md-and-down')} {
      max-height: 64px;
    }

    &--expanded {
      max-height: 800px;
      margin-bottom: 24px;
    }
  }

  &__footer {
    align-items: center;
    display: flex;
    justify-content: center;
    position: relative;

    &:before {
      @include pseudo($width: calc(100% + 48px), $height: 1px);
      border-top: 1px solid $color-medium-grey;
      top: 0;
    }

    .v-btn {
      .v-btn__content {
        font-size: 18px !important;
      }
    }

    &-icon {
      transition: transform 150ms ease-out;

      &--expanded {
        transform: rotate(180deg);
      }
    }
  }
}
</style>
