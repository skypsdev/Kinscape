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

    <h3 class="profile-member__title my-8">
      {{
        $i18n.t("users.profile_page.edit_member_title", {
          communityName: member.community.name
        })
      }}
      {{
        $i18n.t(`families.member_roles.${member.role}`)
      }}
    </h3>
    <slot></slot>
  </div>
</template>

<script>
import { mapActions, mapState } from 'vuex'
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
      updateMember: 'members/updateMember'
    }),
    handleChange() {
      this.saveCommunityChanges(this)
    },
    saveCommunityChanges: debounce((ctx) => {
      ctx.updateMember({
        id: ctx.member.id,
        form: { ...ctx.form }
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
</style>

