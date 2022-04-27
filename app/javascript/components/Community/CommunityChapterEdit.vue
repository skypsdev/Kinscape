<template>
  <div class="chapter-edit">
    <div class="d-flex mb-4">
      <v-text-field
          class="chapter-title__input"
          v-model="form.title"
          :placeholder="$i18n.t('sections.title_placeholder')"
          outlined
          hide-details
          single-line
          color="primary"
          type="text"
          @keydown="handleChangeTitle"
      />

      <v-btn
          class="ml-2"
          outlined
          x-large
          color="primary"
          @click="openChapterDeleteDialog"
      >
        <v-icon>mdi-delete-outline</v-icon>
        <span class="pl-2 hidden-sm-and-down">
          {{$i18n.t('stories.chapters.delete')}}
        </span>
      </v-btn>
    </div>

    <div>
      <RichEditor
          :current-user="currentUser"
          :input-name="'section_content_' + chapter.id"
          :value="richEditorValue"
          :upload-in-progress="false"
          :families="[community]"
          :initial-state="true"
          @editor-change="handleChangeContent"
      />
    </div>

  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import RichEditor from '../shared/RichEditor'
import debounce from "lodash/debounce";

export default {
  components: { RichEditor },
  props: {
    chapter: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      form: {
        title: '',
        body: ''
      },
      richEditorPlaceholder: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
    }
  },
  computed: {
    ...mapState({
      community: state => state.families.community,
      currentUser: state => state.core.user
    }),
    richEditorValue() {
      const body = this.chapter.attributes.rich_body.body
      return this.richEditorPlaceholder === body ? '' : body
    }
  },
  mounted () {
    const {title, rich_body: richBody} = this.chapter.attributes
    this.form = {
      title: title === this.$i18n.t('sections.title_placeholder') ? '' : title,
      body: richBody.body === this.richEditorPlaceholder ? '' : richBody.body,
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      createNewChapter: 'families/createNewChapter',
      updateChapter: 'families/updateChapter',
      setSnackbar: 'layout/setSnackbar'
    }),
    openChapterDeleteDialog() {
      this.setDialog({
        title: this.$i18n.t('stories.chapters.delete'),
        component: 'ChapterDeleteDialog',
        data: {
          section: this.chapter,
          viewType: 'community'
        }
      })
    },
    handleChangeTitle() {
      this.saveChapterChanges(this)
    },
    handleChangeContent(event) {
      let body = event.target.inputElement.value
      const htmlTags = Array.from(event.target.childNodes).map(node => node.localName)

      if (!htmlTags.includes('h1')) {
        body = body.replace('<div><!--block--><br></div>', '')
      }
      if (this.chapter.attributes.rich_body.body !== body) {
        this.form.body = body
        this.saveChapterChanges(this)
      }
    },
    saveChapterChanges: debounce((ctx) => {
      ctx.updateChapter({
        id: ctx.chapter.id,
        form: {
          title: ctx.form.title || ctx.$i18n.t('sections.title_placeholder'),
          richBody: {
            body: ctx.form.body
          },
          object_type: 'Family',
          object_id: ctx.community.id
        }
      })
    }, 700)
  }
}
</script>

<style lang="scss">
.chapter-edit {
  .chapter-title__input {
    font-size: 18px;
    color: #4B4B4B;
    &.v-text-field {
      .v-input__control {
        min-height: 48px !important;
      }
      .v-input__slot {
        min-height: 48px !important;
      }
      .v-label {
        top: 6px !important;
      }
      &--outlined fieldset {
        border-color: $color-light-grey;
      }
    }
  }
}

</style>
