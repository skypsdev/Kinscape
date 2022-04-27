<template>
  <v-container class="vault__grid">
    <slot></slot>
    <div class="vault__items d-flex flex-wrap justify-start">
      <div class="px-2 pb-2" v-for="(file, index) in files" :key="index">
        <VaultItemCard
          :url="getCoverUrl(file.tempId)"
          :type="getType(file)"
          :is-selected="selected.includes(file.tempId)"
          @click.native="toggleSelected(file.tempId)"
        >
          <div class="v-card__title vault-card__title">
            <span :title="file.filename">{{ file.filename }}</span>
          </div>
        </VaultItemCard>
      </div>
    </div>
  </v-container>
</template>

<script>
import { xor as _xor } from 'lodash'

import VaultItemCard from '@/components/Vault/VaultItemCard.vue'
export default {
  name: "UploadDialogFiles",
  components: {
    VaultItemCard
  },
  model: {
    prop: 'selected'
  },
  props: {
    isMultiple: {
      type: Boolean,
      default: false,
      required: true
    },
    getCoverUrl: {
      type: Function,
      default: null,
      required: true
    },
    files: {
      type: Array,
      default: () => [],
      required: true
    },
    selected: {
      type: Array,
      default: () => [],
      required: true
    }
  },
  methods: {
    async toggleSelected(id) {
      if (!this.isMultiple && !this.selected.includes(id)) {
        this.$emit('input', [])
      }

      await this.$nextTick()

      this.$emit('input', _xor(this.selected, [id]))
    },
    matchTypes(type, matchArray) {
      return matchArray.some(match => type?.match(match))
    },

    getType(file) {
      let result
      const { contentType } = file

      switch (true) {
        case this.matchTypes(contentType, [/video/]):
          result = 'video'
          break

        case this.matchTypes(contentType, [/jpeg/, /png/, /gif/]):
          result = 'image'
          break

        case this.matchTypes(contentType, [/audio/]):
          result = 'audio'
          break

        default:
          result = 'other'
          break
      }

      return result
    }
  }
}
</script>

<style lang="scss" scoped>
@import "@/components/Vault/VaultItemTitle.scss";

.vault {
  &__wrap {
    margin-top: 23px;
    padding-bottom: 24px;
  }

  &__grid {
    width: 664px;
  }
  &__items {
    margin-left: -8px;
    margin-right: -8px;

    overflow-y: auto;
    max-height: 432px;
  }

  &-card {
    height: 108px !important;
    width: 108px !important;
  }
}
</style>