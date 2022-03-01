<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        <div class="subtitle-2">
          {{ $i18n.t('requests.message.general') }}
        </div>
        <v-form
          ref="conversationForm"
          v-model="isFormValid"
        >
          <div class="subtitle-1">Community:</div>
          <v-select
            dense
            outlined
            color="primary"
            item-text="attributes.name"
            item-value="id"
            :rules="[rules.required]"
            :items="families"
            :disabled="isLoading"
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
            :items="filteredMembers"
            :disabled="isLoading"
            :rules="[rules.required]"
            v-model="form.kinshipsIds"
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
          class="ma-1"
          :disabled="isLoading"
          @click="submitForm()"
        >
          Send message
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import rules from '../../utils/validators'
import {mapActions, mapState} from 'vuex'
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
      message: ''
    }
  }),
  computed:{
    ...mapState({
      dialog: state => state.layout.dialog,
      families: state => state.families.simpleList.families,
      members: state => state.families.simpleList.members,
      isLoading: state => state.families.isLoading,
      currentUser: state => state.core.user
    }),
    filteredMembers() {
      if (!this.form.familyId ) return []
      if (!this.members.length ) return []
      const family = this.families.find(f => f.id === this.form.familyId)
      const familyKinships = family ? family.relationships.kinships.data : []
      const ids = familyKinships.map((u) => u.id)
      return this.members.filter((member) =>
          member.id !== this.currentUser.id && ids.includes(member.id)
      )
    }
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      sendMessage: 'conversations/sendMessage'
    }),
    submitForm() {
      this.$refs.conversationForm.validate()
      if (this.isFormValid) this.sendMessage(this.form)
    }
  }
}
</script>

<style lang="scss" scoped>
</style>
