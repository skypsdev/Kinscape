<template>
  <DialogContent
    class="set-offline"
    :title="$i18n.t('families.dialog_set_offline_member.title')"
    @close="$emit('close')"
  >
    <template v-slot:content>
      <v-container class="pt-12 px-16">
        <p
          class="dialog-content__text text-center"
          v-html="
            $i18n.t('families.dialog_set_offline_member.content_text', {
              name: member.name
            })
          "
        ></p>
      </v-container>
    </template>
    <template v-slot:actions>
      <div class="my-4">
        <v-btn
          color="primary"
          elevation="0"
          x-large
          rounded
          outlined
          @click="$emit('close')"
        >
          {{ $i18n.t('families.dialog_set_offline_member.actions.cancel') }}
        </v-btn>
        <v-btn
          class="v-btn--active"
          color="primary"
          elevation="0"
          x-large
          rounded
          outlined
          @click="changeToOfflineMember"
        >
          {{ $i18n.t('families.dialog_set_offline_member.actions.confirm') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions } from 'vuex'
import { setOfflineMember } from '../../repositories/kinships-repository'
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
    async changeToOfflineMember() {
      const id = this.member.id
      const familyId = this.member.familyId || this.member.family_id

      await setOfflineMember(id, {})
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
.set-offline {
  position: relative;

  &:before {
    background-color: $color-lightest_purple;
    content: url("data:image/svg+xml,%3Csvg width='780' height='53' fill='none' xmlns='http://www.w3.org/2000/svg'%3E%3Cpath d='M621.563 43.325c43.258-6.54 114.331-.472 145.485 4.337C773.601 48.673 780 43.584 780 36.954V0H0v29.644C0 41 6.094 49 30.469 51.5c29.222 2.997 90.718-1.334 161.823-8.175 71.105-6.84 138.791 0 209.896 6.841 71.104 6.841 174.126 0 219.375-6.84Z' fill='%23F9F8FF'/%3E%3C/svg%3E");
    display: block;
    height: 190px;
    padding-top: 190px;
    position: absolute;
    top: 0;
    width: 100%;
  }

  .dialog-content {
    position: relative;
    z-index: 1;

    &__text {
      font-size: 18px;
      line-height: 1.6rem;
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
