<template>
  <DialogContent class="remove_member">
    <template v-slot:content>
      <v-container class="pt-12 px-16">
        <v-img
          class="mb-12 text-center"
          height="100"
          contain
          :src="require('../../assets/images/leave-member.svg')"
        />
        <p
          class="remove_member__description text-center"
          v-html="
            $i18n.t('communities.member.header.leaveDialog.description')
          ">
        </p>
        <div
          class="text-center remove_member__keep_offline"
          @click="keepProfile"
        >
          {{ $i18n.t('communities.member.header.leaveDialog.keepOffline') }}
        </div>
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
          @click="removeMember"
        >
          {{ $i18n.t('communities.member.header.leaveCommunity') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>
<script type="text/javascript">
  import DialogContent from '../../components/Layout/Dialog/DialogContent'
  import {mapActions} from "vuex";

  export default {
    components: {
      DialogContent
    },
    methods: {
      ...mapActions({
        closeDialog: 'layout/closeDialog',
        setDialog: 'layout/setDialog'
      }),
      removeMember() {
        this.setDialog({
          component: 'RemoveContentDialog',
          title: this.$i18n.t('communities.member.header.leaveDialog.contentTitle')
        })
      },
      keepProfile () {
        this.setDialog({
          component: 'KeepProfileDialog',
          title: this.$i18n.t('communities.member.header.leaveDialog.contentTitle')
        })
      }
    }
  }
</script>
<style lang="scss" scoped>
.remove_member {
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
  &__keep_offline {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 19px;
    align-items: center;
    text-align: center;
    text-decoration-line: underline;
    color: $color-required;
    cursor: pointer;
  }
}
</style>
