<template>
  <v-simple-table height="310px">
    <template v-slot:default>
      <thead class="people-list__head">
        <tr>
          <th class="people-head__th text-left">
            <div>{{ $i18n.t("mylives.my_people.table_th_name") }}</div>
          </th>
          <th class="text-left">
            <div>{{ $i18n.t("mylives.my_people.table_th_date") }}</div>
          </th>
          <th class="text-left">
            <div>{{ $i18n.t("mylives.my_people.table_th_actions") }}</div>
          </th>
        </tr>
      </thead>

      <tbody class="people-list__body">
        <tr v-for="person in data" class="people-body__tr" :key="person.name">
          <td class="people-body__td">
            <div class="people-body__outer">
              <div class="people-body__name">
                <v-avatar size="28px">
                  <img
                    alt="Avatar"
                    :src=" person.attributes.avatarUrl || require('@/../assets/images/avatar')"
                  />
                </v-avatar>
                {{ person.attributes.nickname }}
              </div>
            </div>
          </td>
          <td class="people-body__td">
            <div class="people-body__outer">
              <div class="people-body__date">
                {{
                  person.attributes.createdAt
                    ? $i18n.l(
                        "date.formats.default",
                        person.attributes.createdAt
                      )
                    : "-"
                }}
              </div>
            </div>
          </td>
          <td class="people-body__td">
            <div class="people-body__outer">
              <!-- message btn -->
              <v-btn
                icon
                outlined
                rounded
                color="#8B78FE"
                height="32"
                width="32"
                class="mr-6"
                @click="sendMessage(person.id, person.attributes.familyId)"
              >
                <v-img
                  max-width="16.67px"
                  :src="require('@/assets/images/my-people/markunread.svg')"
                />
              </v-btn>

              <!-- slot "unfollow-btn" -->
              <slot :personId="person.id" name="unfollow-btn">
                <VMenu
                  :toggle="false"
                  :items="[
                    {
                      title: $i18n.t('mylives.my_people.remove_from'),
                      action: 'unfollow',
                    },
                  ]"
                  @unfollow="unfollow({ id: person.id, instance })"
                >
                  <template v-slot:activator="{ on, attrs }">
                    <v-btn
                      v-bind="attrs"
                      v-on="on"
                      icon
                      outlined
                      rounded
                      color="#8B78FE"
                      height="32"
                      width="32"
                    >
                      <v-icon>mdi-dots-horizontal</v-icon>
                    </v-btn>
                  </template>
                </VMenu>
              </slot>
            </div>
          </td>
        </tr>
      </tbody>
    </template>
  </v-simple-table>
</template>

<script>

import VMenu from '@/components/Menu/Menu.vue'
export default {
  name: "PeopleList",
  components: { VMenu },
  props: {
    data: { type: Array, default: () => [], required: true },
    unfollow: {
      type: Function,
      default: () => null
    },
    sendMessage: {
      type: Function,
      default: () => null
    },
    instance: {
      type: String,
      default: '',
      required: true
    }
  },
  data() {
    return {
      toggleMenu: false
    }
  },
}
</script>

<style lang="scss">
$grey-one: #eeeeee;
/* -------------------------------------------------------------------------- */
/*                                TABLE STYLES                                */
/* -------------------------------------------------------------------------- */

/* ---------------------------------- thead --------------------------------- */
.people-list__head {
  * {
    border: none !important;
  }
  th {
    padding: 0 0 12px 0 !important;
    height: auto !important;

    div {
      padding-left: 20px;
      padding-top: 6px;
      padding-bottom: 6px;
      background: $color-light-grey;

      font-family: Enriqueta;
      font-weight: bold;
      font-size: 16px;
      line-height: 21px;
      display: flex;
      align-items: flex-end;

      color: $color-tertiary;
    }
  }

  th {
    &:first-child {
      padding-left: 16px !important;
      div {
        border-top-left-radius: 5px;
        border-bottom-left-radius: 5px;
      }
    }

    &:last-child {
      padding-right: 16px !important;
      div {
        border-top-right-radius: 5px;
        border-bottom-right-radius: 5px;
      }
    }
  }
}

/* ---------------------------------- tbody --------------------------------- */
.people-body {
  &__tr:hover {
    cursor: pointer;
    background: none !important;
    .people-body__outer {
      background: $grey-one !important;
    }
  }
  &__td {
    border: none !important;
    padding: 4px 0 !important;
    width: 250px;
    &:first-child {
      padding-left: 16px !important;
      .people-body__outer {
        border-top-left-radius: 5px;
        border-bottom-left-radius: 5px;
      }
    }

    &:last-child {
      padding-right: 16px !important;
      .people-body__outer {
        border-top-right-radius: 5px;
        border-bottom-right-radius: 5px;
      }
    }
  }
  &__outer {
    @include transition();
    @include center-flex-y();

    height: 100%;
    padding-left: 25px;
    background: $color-dark-white;
  }

  &__name {
    font-family: Lato;
    font-weight: bold;
    font-size: 16px;
    line-height: 24px;

    display: flex;
    align-items: center;

    color: $color-tertiary;

    .v-avatar {
      margin-right: 15.5px;
    }
  }

  &__date {
    font-family: Lato;
    font-weight: normal;
    font-size: 16px;
    line-height: 19px;

    color: $color-tertiary;
  }
}
</style>
