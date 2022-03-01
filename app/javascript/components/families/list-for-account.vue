<template>
  <div
    v-if="familyList && familyList.length>0"
    id="list-for-account"
  >
    <div
      v-for="f in familyList"
      :key="f.id"
      class="account__family"
      @mouseover="selectedFamily = f"
      @mouseleave="selectedFamily = null"
    >
      <div class="account__family-title">
        <a :href="'/communities/' + f.id">{{ f.attributes.name }}</a>
        <a
          v-if="!f.attributes.is_connected_by_current_user
            && f == selectedFamily"
          v-tooltip="'Leave ' + f.attributes.name"
          class="remove-family"
          style="cursor:pointer;"
          @click="showConfirmModal"
        >
          <i
            class="fa fa-minus-circle"
            aria-hidden="true"
          />
          Leave Community
        </a>
      </div>
      <div
        v-if="f.is_connected_by_current_user"
        class="account__family-connector"
      >
        {{ $i18n.t('account.families.you_are_connector') }}
      </div>
      <div
        v-else
        class="account__family-connector"
      >
        {{ $i18n.t('account.families.connector',
                   { connector_name: f.attributes.connector_name }) }}
      </div>
      <div v-if="f.attributes.is_connected_by_current_user">
        Storage: {{ f.attributes.family_media_size }}
      </div>
    </div>
    <confirmation-remove-family-modal
      :family="family"
      :show-confirm="showConfirm"
      @show-warning-modal="showWarningModal"
      @hide-confirm-modal="hideConfirmModal"
    />
    <warning-remove-family-modal
      :family="family"
      :current-user="currentUser"
      :show-warning="showWarning"
      @removed-family="removeFamily"
      @hide-warning-modal="hideWarningModal"
    />
  </div>
  <div
    v-else-if="familyList.length === 0"
    class="account__family"
  >
    No Communities
  </div>
</template>

<script>
import ConfirmationRemoveFamilyModal from './confirmation-remove-dialog.vue'
import WarningRemoveFamilyModal from './warning-remove-dialog.vue'

import { mapState} from 'vuex'
export default {
  components: { ConfirmationRemoveFamilyModal, WarningRemoveFamilyModal },
  props: {
    familyList: {
      type: Array,
      required: true
    }
  },
  data () {
    return {
      selectedFamily: {},
      family: {},
      // familyList: this.familyList,
      showConfirm: false,
      showWarning: false
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    })
  },
  methods: {
    showConfirmModal () {
      this.family = this.selectedFamily
      this.showConfirm = true
    },
    removeFamily (family) {
      // TODO Fix mutating prop
      // eslint-disable-next-line vue/no-mutating-props
      this.familyList = this.familyList.filter(f => f.id !== family.id)
    },
    hideConfirmModal () {
      this.showConfirm = false
    },
    showWarningModal () {
      this.showConfirm = false
      this.showWarning = true
    },
    hideWarningModal () {
      this.showWarning = false
    }
  }
}
</script>

<style lang="scss">
  .modal.confirmation-dialog.warning-family .controls-block {
    button.ok {
      background: red;
      border: red;
    }
  }
</style>
