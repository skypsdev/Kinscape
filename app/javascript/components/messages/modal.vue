<template>
  <div class="modal-inner-wrapper request-story-modal">
    <h2 class="form-title msg_title">
      {{ $i18n.t('requests.title') }}
    </h2>
    <form
      name="messageForm"
      novalidate="true"
      @submit.prevent="sendMessage"
    >
      <div v-if="!user || currentUser.id.toString() === user.id">
        <center>
          <p class="form-message">
            {{ $i18n.t('requests.message.general') }}
          </p>
        </center>
        <div class="form-group">
          <div class="input select required">
            <label
              for="family_id"
              class="select required"
            >
              <abbr title="required">*</abbr>
              Community:
            </label>
            <select
              id="family_id"
              v-model="familyId"
              name="family_id"
              class="select required"
              @change="resetSelectedMembers"
            >
              <option :value="null">
                Select Community...
              </option>
              <option
                v-for="family in families"
                :key="family.id"
                :value="family.id"
              >
                {{ family.attributes.name }}
              </option>
            </select>
          </div>
        </div>
        <div class="form-group">
          <div class="input select required">
            <label
              for="user_id"
              class="select required"
            >
              <abbr title="required">*</abbr>
              Recipients:
            </label>
            <dropdown
              :data="membersFromSelectedFamily"
              :cb-changed="changedMultiselect"
              :cb-item-changed="selectedItem"
              :cb-custom-selected-text="selectedText"
              :fix-list-width="false"
              placeholder="Select Recipients..."
              multiple
            />
          </div>
        </div>
      </div>
      <div v-else>
        <p class="form-message">
          {{ $i18n.t('requests.message.custom', { user_name: user.name }) }}
        </p>
      </div>
      <div class="input text required request_message">
        <label
          class="text required"
          for="request_message"
        >
          <abbr title="required">*</abbr>
          Message:
        </label>
        <textarea
          id="request_message"
          v-model="message"
          rows="2"
          required="required"
          class="text required"
          name="message"
        />
      </div>
      <div class="boolean-group">
        <input
          type="submit"
          value="Send message"
          :disabled="!userId || !message"
        >
        <a
          href="#"
          class="form-cancel"
          @click="$modal.hide(modalName)"
        >Cancel</a>
      </div>
    </form>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { MessagesRepository } from '../../repositories'

export default {
  props: {
    user: {
      type: Object,
      default: null
    },
    currentUser: {
      type: Object,
      required: true
    },
    modalName: {
      type: String,
      required: true
    },
    success: Boolean
  },
  data () {
    return {
      familyId: '',
      userId: this.user ? [this.user.id] : null,
      message: null,
      selectedMembers: null
    }
  },
  computed: {
    ...mapState({
      families: state => state.families.simpleList.families,
      members: state => state.families.simpleList.members,
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    }),
    membersFromSelectedFamily () {
      if (this.selectedMembers) return this.selectedMembers
      if (!this.familyId) return []
      const family = this.families.find(f => f.id === this.familyId)
      const familyUsers = family ? family.relationships.users.data : []
      const ids = familyUsers.map((u) => u.id)
      let members = this.members.filter((member) =>
        member.id !== this.currentUser.id.toString() && ids.includes(member.id))
      members = members.map((member) => {
        return { label: member.attributes.name, value: member.id }
      })
      members.unshift({ label: 'Select All', value: null })
      return members
    }
  },
  methods: {
    sendMessage: async function () {
      if (this.$route.name === 'member' && this.familyId === null) {
        // TODO-SELECTED-FAMILY-ID: use correct family id
        this.familyId = this.chosenFamilyId
      }
      try {
        await MessagesRepository.sendMessage(
          { family_id: this.familyId,
            user_id: this.userId,
            message: this.message
          }
        )
        this.$modal.hide(this.modalName)
        this.$emit('success')
      } catch (error) {
        this.$emit('failure')
      }
    },
    selectedItem (item) {
      if (item.label !== 'Select All') return
      const stringifyMembers = JSON.stringify(this.membersFromSelectedFamily)
      this.selectedMembers = JSON.parse(stringifyMembers)
      this.selectedMembers.forEach(d => {
        !d.disabled && (d.selected = item.selected)
      })
      this.selectUsers(this.selectedMembers)
    },
    changedMultiselect (selected) {
      if (this.hasAll(selected)) return
      this.selectUsers(selected)
    },
    selectedText (selected, defaultFn) {
      if (this.hasAll(selected)) {
        return 'All'
      }
      return defaultFn(selected)
    },
    resetSelectedMembers () {
      this.selectedMembers = null
    },
    hasAll (selected) {
      let hasAll = false
      selected.forEach(s => s.label === 'Select All' && (hasAll = true))
      return hasAll
    },
    selectUsers (selected) {
      this.userId = selected.map(member => {
        return member.value
      }).filter(value => {
        return value
      })
    }
  }
}
</script>

<style scoped>
  .modal-inner-wrapper {
    padding: 2em;
  }

  .form-wrapper {
    margin: 0;
    padding: 0;
    width: 100%;
    float: none;
  }

  .form-wrapper .form-message {
    margin-bottom: 0.8em;
  }

  #family_id {
    width: 100%;
    height: 28px;
    line-height: 28px;
    border-radius: 3px;
    border: 1px solid #b3c1d8;
    padding: 0 20px 0 10px;
    color: #4c5565;
    cursor: pointer;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
    background-color: white;
  }

  .modal-inner-wrapper
  .boolean-group
  a.form-cancel {
    float: left;
    width: 48%;
    -webkit-transition: all 0.15s linear;
    transition: all 0.15s linear;
    border-radius: 3px;
    border: 1px solid #8c98a8;
    display: inline-block;
    font-weight: 300;
    letter-spacing: 1px;
    line-height: normal;
    text-align: center;
    text-transform: none;
    cursor: pointer;
    font-size: 1em;
    padding: 0.8em;
    background: transparent;
    color: #8c98a8;
    display: inline-block;
  }

  @media screen and (max-width: 760px) {
    .modal-inner-wrapper
    .boolean-group
    a.form-cancel {
      float: none;
      width: 100%;
    }
  }
</style>

<style lang="scss">
  h2.form-title.msg_title{
    padding: 0px;
    margin: 0px;
  }
  p.form-message{
    margin-bottom: 10px;
  }
  .hsy-dropdown {
    width: 100% !important;
    font-size: 13px;
    margin-bottom: 1.5em;
  }

  .hsy-dropdown>.selected {
    font-size: 1.25em !important;
    background-position: 99.5% !important;
    line-height: 26px !important;
    border-radius: 4px !important;
    background-size: 9px !important;
    background: url('data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmN\
      vZGluZz0iVVRGLTgiPz4KPHN2ZyB3aWR0aD0iMTBweCIgaGVpZ2h0PSIxNnB4IiB2aWV3Qm9\
      4PSIwIDAgMTAgMTYiIHZlcnNpb249IjEuMSIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzI\
      wMDAvc3ZnIiB4bWxuczp4bGluaz0iaHR0cDovL3d3dy53My5vcmcvMTk5OS94bGluayI+CiA\
      gICA8ZyBpZD0iUGFnZS0xIiBzdHJva2U9Im5vbmUiIHN0cm9rZS13aWR0aD0iMSIgZmlsbD0\
      ibm9uZSIgZmlsbC1ydWxlPSJldmVub2RkIj4KICAgICAgICA8ZyB0cmFuc2Zvcm09InRyYW5\
      zbGF0ZSgtNTg5LjAwMDAwMCwgLTI4Ny4wMDAwMDApIiBmaWxsPSIjNEM1NTY1Ij4KICAgICA\
      gICAgICAgPGcgaWQ9Ikdyb3VwLTMiIHRyYW5zZm9ybT0idHJhbnNsYXRlKDM1MS4wMDAwMDA\
      sIDExMi4wMDAwMDApIj4KICAgICAgICAgICAgICAgIDxnIGlkPSJidXR0b24tMzMtY29weSI\
      gdHJhbnNmb3JtPSJ0cmFuc2xhdGUoMTI2LjAwMDAwMCwgMTY4LjY0MDAxNSkiPgogICAgICA\
      gICAgICAgICAgICAgIDxnIGlkPSJHcm91cC04IiB0cmFuc2Zvcm09InRyYW5zbGF0ZSgxMTI\
      uMDAwMDAwLCA2LjAwMDAwMCkiPgogICAgICAgICAgICAgICAgICAgICAgICA8cG9seWdvbiB\
      pZD0iVHJpYW5nbGUtMiIgcG9pbnRzPSIwLjc3MjUxMDI4OCA5LjkzODAyOTMgOS43NzI1MTA\
      yOSA5LjkzODAyOTMgNS4yNzI1MTAyOSAxNS45MzgwMjkzIj48L3BvbHlnb24+CiAgICAgICA\
      gICAgICAgICAgICAgICAgIDxwb2x5Z29uIGlkPSJUcmlhbmdsZS01IiB0cmFuc2Zvcm09InR\
      yYW5zbGF0ZSg1LjI3MjUxMCwgMy45MzgwMjkpIHNjYWxlKDEsIC0xKSB0cmFuc2xhdGUoLTU\
      uMjcyNTEwLCAtMy45MzgwMjkpICIgcG9pbnRzPSIwLjc3MjUxMDI4OCAwLjkzODAyOTI5NyA\
      5Ljc3MjUxMDI5IDAuOTM4MDI5Mjk3IDUuMjcyNTEwMjkgNi45MzgwMjkzIj48L3BvbHlnb24\
      +CiAgICAgICAgICAgICAgICAgICAgPC9nPgogICAgICAgICAgICAgICAgPC9nPgogICAgICA\
      gICAgICA8L2c+CiAgICAgICAgPC9nPgogICAgPC9nPgo8L3N2Zz4K') no-repeat 100%;
  }

  .hsy-dropdown>.list>.inner {
    overflow-y: scroll;
    max-height: 200px;
  }
</style>
