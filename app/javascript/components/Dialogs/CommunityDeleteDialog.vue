<template>
  <DialogContent>
    <template v-slot:content>
      <div class="mt-2">
        {{ $i18n.t('families.dialog_delete_community.content_text') }}
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
          {{ $i18n.t('families.dialog_delete_community.actions.cancel') }}
        </v-btn>
        <v-btn
            x-large
            rounded
            color="primary"
            elevation="0"
            class="ma-1"
            @click="deleteFamily"
        >
          {{ $i18n.t('families.dialog_delete_community.actions.confirm') }}
        </v-btn>
      </div>
    </template>
  </DialogContent>
</template>

<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import {mapActions, mapState} from 'vuex'
import familiesRepository from "../../repositories/families-repository";

export default {
  components: {
    DialogContent
  },
  computed:{
    ...mapState({
      community: store => store.families.community,
    }),
    communityId() {
      return this.$route.params.id
    },
  },
  methods: {
    ...mapActions({
      closeDialog: 'layout/closeDialog',
      setSnackbar: 'layout/setSnackbar',
    }),
    async deleteFamily () {
      try {
        await familiesRepository.removeFamily(this.communityId)
        this.setSnackbar(
            this.$i18n.t(
                'families.removed',
                { title: this.community.name }
            )
        )
        this.$router.push({ name: 'communities' })
      } catch (error) {
        console.error(error)
        this.setSnackbar(
            this.$i18n.t('flashes.alert.unauthorized')
        )
      } finally {
        this.closeDialog()
      }
    }
  }
}
</script>
