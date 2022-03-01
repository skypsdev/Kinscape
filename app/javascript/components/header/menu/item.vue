<template>
  <a
    class="open-request-story-modal"
    :class="{ 'guest': currentUser.guest }"
    :title="$i18n.t('header.message_title')"
    href=""
    @click.prevent="showMessageModal"
  >
    <slot />
    <portal
      v-if="portalId.length"
      :to="portalName"
      :disabled="disablePortal"
    >
      <modal
        :name="modalName"
        :adaptive="true"
        :width="720"
        height="auto"
      >
        <transition name="fade">
          <message-modal
            :user="user"
            :current-user="currentUser"
            :modal-name="modalName"
            @success="success"
            @failure="failure"
          />
        </transition>
      </modal>
    </portal>
    <confirmation-dialog
      :dialog-name="upgradeModalName"
      :dialog-title="$i18n.t('account.upgrade_account_confirm.title')"
      :dialog-message="$i18n.t('account.upgrade_account_confirm.content')"
      :confirm-button="$i18n.t('account.upgrade_account_confirm.ok')"
      @confirmation-ok="billingPage()"
      @confirmation-cancel="$modal.hide(upgradeModalName)"
    />
  </a>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'

import MessageModal from '../../messages/modal'
import ConfirmationDialog from '../../shared/confirmation-dialog'

export default {
  components: { MessageModal, ConfirmationDialog },
  props: {
    user: {
      type: Object,
      default: null
    },
    currentUser: {
      type: Object,
      required: true
    },
    portalId: {
      type: String,
      default () {
        return this.user ? '#vue-modal-' + this.user.id : '#vue-modal-0'
      }
    },
    portalName: {
      type: String,
      default () {
        return ''
      }
    },
    modalName: {
      type: String,
      default () {
        return this.user ? 'message-modal-' + this.user.id : 'message-modal'
      }
    },
    upgradeModalName: {
      type: String,
      default () {
        return 'confirmation-upgrade-account'
      }
    },
    disablePortal: Boolean
  },
  data () {
    return {
      showConfirm: false
    }
  },
  computed: {
    ...mapGetters([
      'flashMessage'
    ])
  },
  methods: {
    ...mapActions([
      'successFlashMessage',
      'failureFlashMessage'
    ]),
    showMessageModal () {
      if (!this.currentUser.guest) {
        this.$modal.show(this.modalName)
      } else {
        this.$modal.show(this.upgradeModalName)
      }
    },
    success () {
      this.successFlashMessage(this.$i18n.t('requests.success'))
    },
    failure () {
      this.failureFlashMessage(this.$i18n.t('requests.failure'))
    },
    billingPage () {
      window.location.href = '/billing/cards/new'
    }
  }
}
</script>

<style scoped>
  * {
    line-height: normal;
  }
</style>
