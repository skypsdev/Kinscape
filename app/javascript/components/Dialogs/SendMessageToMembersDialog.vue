<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        <div class="subtitle-2">
          {{ $i18n.t('requests.message.general') }}
        </div>
        <v-form ref="conversationForm" v-model="isFormValid">
          <div class="subtitle-1">Community:</div>
          <v-select
            dense
            outlined
            color="primary"
            item-text="attributes.name"
            item-value="id"
            :rules="[rules.required]"
            :items="families"
            :disabled="isLoading || locked"
            v-model="form.familyId"
          />
          <div class="subtitle-1">Recipients:</div>
          <v-select
            dense
            outlined
            multiple
            color="primary"
            item-text="attributes.nickname"
            item-value="id"
            :menu-props="{
              minWidth: '360px',
              maxHeight: '184px',
              nudgeBottom: '10px',
              nudgeRight: '15px'
            }"
            :items="filteredMembers"
            :disabled="isLoading || locked"
            :rules="[rules.required]"
            v-model="form.kinshipsIds"
          />
          <div class="subtitle-1">Subject:</div>
          <v-text-field
            outlined
            single-line
            :rules="[rules.required]"
            v-model="form.subject"
          />
          <div class="subtitle-1">Message:</div>
          <v-textarea
            outlined
            :rules="[rules.required]"
            v-model="form.message"
          />
        </v-form>
      </div>
    </template>
    <template v-slot:actions>
      <div>
        <v-btn
          x-large
          rounded
          outlined
          color="primary"
          elevation="0"
          class="ma-1"
          @click="closeDialog()"
        >
          Cancel
        </v-btn>
        <v-btn
          x-large
          rounded
          color="primary"
          elevation="0"
          class="ma-1 send-message-cvr-btn"
          :disabled="isLoading"
          @click="submitForm()"
        >
          {{ $i18n.t('helpers.submit.request.create') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import { mapActions, mapState } from 'vuex'

import DialogContent from '@/components/Layout/Dialog/DialogContent'
import rules from '@/utils/validators'

export default {
  components: {
    DialogContent
  },
  data: () => ({
    rules,
    isFormValid: false,
    form: {
      familyId: '',
      kinshipsIds: '',
      message: '',
      subject: ''
    }
  }),
  computed: {
    ...mapState({
      dialog: (state) => state.layout.dialog.data,
      currentUser: (state) => state.core.user,

      families: (state) => state.families.simpleList.families,
      members: (state) => state.conversations.recipients.members,
      isLoading: (state) => state.conversations.loading
    }),
    locked() {
      return this.dialog?.locked ?? false
    },
    filteredMembers() {
      if (!this.form.familyId) return []
      if (!this.members.length) return []

      const family = this.families.find((f) => f.id === this.form.familyId)
      const familyKinships = family ? family.relationships.kinships.data : []
      const ids = familyKinships.map((u) => u.id)

      return this.members.filter(
        (member) => member.id !== this.currentUser.id && ids.includes(member.id)
      )
    }
  },
  mounted() {
    if (this.locked) {
      this.form = {
        ...this.form,
        familyId: this.dialog.familyId,
        kinshipsIds: this.dialog.kinshipsIds
      }
    }
  },
  created() {
    this.getRecipients()
  },
  methods: {
    ...mapActions('layout', ['closeDialog']),
    ...mapActions('conversations', ['sendMessage', 'getRecipients']),
    submitForm() {
      this.$refs.conversationForm.validate()
      if (this.isFormValid) this.sendMessage(this.form)
    }
  }
}
</script>
