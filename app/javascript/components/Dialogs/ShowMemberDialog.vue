<template>
  <DialogContent>
    <template v-slot:content>
      <v-container>
        <div
            v-for="(attribute, attributeIndex) in member.profile"
            :key="attributeIndex.toString()"
        >
          <v-row
              v-if="isString(attribute)"
              no-gutters
          >
            <v-col cols="12">
              <h4 class="show-member__heading f--tertiary mr-3 mt-4">
                {{ $i18n.t(`communities.member.edit.dialog.${attributeIndex}`) }}
              </h4>
            </v-col>
            <v-col>
              <p class="show-member__attribute mb-0">
                {{ member.profile[attributeIndex] }}
              </p>
            </v-col>
          </v-row>
          <v-row v-else no-gutters>
            <div v-for="(item, itemIndex) in attribute" :key="itemIndex" class="d-flex flex-column w--100">
              <div class="show-member__heading mt-5">
                {{ $i18n.t(`communities.member.edit.dialog.${attributeIndex}`) }} - {{ item.name }}
              </div>
              <v-row class="mt-0" no-gutters>
                <v-col cols="11" class="pt-1">
                  <span
                      class="show-member__attribute"
                  >
                    {{ item.value }}
                  </span>
                </v-col>
              </v-row>
            </div>
          </v-row>
          <v-divider class="mt-6" />
        </div>
      </v-container>
    </template>
  </DialogContent>
</template>
<script>
import DialogContent from '../../components/Layout/Dialog/DialogContent'
import { mapState } from 'vuex'

export default {
  components: {
    DialogContent
  },
  computed: {
    ...mapState({
      member: state => state.members.member,
    }),
  },
  mounted() {
    this.form = JSON.parse(JSON.stringify({ ...this.member.profile }))
  },
  methods: {
    isString(value) {
      return typeof value === 'string'
    },
  }
}
</script>
<style lang="scss" scoped>
.show-member {
  &__heading {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 13px;
    line-height: 24px;
    color: $color-primary;
  }
  &__attribute {
    font-family: Lato;
    font-style: normal;
    font-weight: bold;
    font-size: 16px;
    line-height: 19px;
  }
}
</style>
