<template>
  <DialogContent
    class="remove-member"
    :title="
      $i18n.t('families.dialog_remove_member.title', { name: this.member.name })
    "
    @close="$emit('close')"
  >
    <template v-slot:content>
      <div class="d-flex align-center justify-center fill-height pa-12 pb-0">
        <p class="dialog-content__text">
          {{ $i18n.t('families.dialog_remove_member.content_text') }}
        </p>
      </div>
    </template>
    <template v-slot:actions>
      <div class="mb-4">
        <v-btn
          color="primary"
          elevation="0"
          x-large
          rounded
          outlined
          @click="$emit('close')"
        >
          {{ $i18n.t('families.dialog_remove_member.actions.cancel') }}
        </v-btn>
        <v-btn
          class="v-btn--active"
          color="primary"
          elevation="0"
          x-large
          rounded
          outlined
          @click="removeMember"
        >
          {{ $i18n.t('families.dialog_remove_member.actions.confirm') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions } from 'vuex'
import { kinshipDelete } from '../../repositories/kinships-repository'
import DialogContent from '../Layout/Dialog/DialogContent'

export default {
  components: {
    DialogContent
  },
  props: {
    member: { type: Object, required: true }
  },
  methods: {
    ...mapActions({
      setError: 'layout/setError'
    }),
    async removeMember() {
      const id = this.member.id
      const familyId = this.member.familyId || this.member.family_id

      await kinshipDelete(id, {})
        .then(() => {
          this.$emit('close')
          if (this.$router.history.current.name !== 'members') {
            this.$router.push({ name: 'members', params: { id: familyId } })
          } else {
            this.$router.go()
          }
        })
        .catch((error) => {
          this.setError(error)
        })
    }
  }
}
</script>

<style lang="scss">
.remove-member {
  height: 392px;

  .dialog-content {
    color: $color-text;
    position: relative;
    z-index: 1;

    &__text {
      font-size: 18px;
      line-height: 1.8rem;
      text-align: center;
    }
  }

  .v-card__actions .v-btn.v-btn {
    padding: 0 24px;

    &.v-size--x-large {
      font-size: 18px;
    }
  }
}
</style>
