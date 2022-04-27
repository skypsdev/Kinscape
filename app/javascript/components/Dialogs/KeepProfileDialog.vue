<template>
  <DialogContent class="keep_profile">
    <template v-slot:content>
      <v-container class="pt-12 px-16">
        <v-img
          height="150"
          contain
          :src="require('../../assets/images/keep-profile.svg')"
        />
        <p
          class="keep_profile__description text-center"
          v-text="
            $i18n.t('communities.member.header.leaveDialog.keepProfileDescription')
          ">
        </p>
      </v-container>
    </template>
    <template v-slot:actions>
      <div class="mb-4">
        <v-btn
          color="primary"
          elevation="0"
          x-large
          rounded
          outlined
          class="px-10"
          @click="closeDialog()"
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
          @click="changeToOfflineMember"
        >
          {{ $i18n.t('communities.member.header.leaveDialog.keepProfile') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script type="text/javascript">
  import DialogContent from '../../components/Layout/Dialog/DialogContent'
  import { setOfflineMember, getKinshipID } from '../../repositories/kinships-repository'
  import { mapActions, mapState } from "vuex";

  export default {
    components: {
      DialogContent
    },
    computed: {
      ...mapState({
        currentUser: state => state.core.user,
        community: state => state.families.community
      })
    },
    methods: {
      ...mapActions({
        closeDialog: 'layout/closeDialog',
        setDialog: 'layout/setDialog',
        setError: 'layout/setError'
      }),
      changeToOfflineMember() {
        this.closeDialog()
        let payload = {
          family_id: this.community.id,
          user_id: this.currentUser.id
        }
        try {
          getKinshipID(payload)
          .then(response => {
            setOfflineMember(response.data.id, {})
            .then(() => {
              this.$router.push({ name: 'communities' })
            })
          })
        }
        catch (error) {
          this.setError(error)
        }
      }
    }
  }
</script>
<style lang="scss" scoped>
.keep_profile {
  &:before {
    @include pseudo(
      $content: url("../../assets/images/dialog-background.svg"),
      $height: 150px,
    );
    background-color: $color-lightest_purple;
    padding-top: 200px;
    top: 0;
  }
  &__description {
    font-size: 16px;
    line-height: 19px;
    color: $color-text;
  }
}
</style>
