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

    <div class="chapter-edit-container">
      <rich-editor
          :current-user="currentUser"
          :input="'section_content_' + chapter.id"
          :value="richEditorValue"
          :upload-in-progress="false"
          :initial-state="true"
          @editor-change="handleChangeContent"
      />
    </div>

  </div>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import RichEditor from '../shared/rich-editor'
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
      member: state => state.members.member,
      currentUser: state => state.core.user
    }),
    richEditorValue() {
      const {html, body} = this.chapter.attributes.rich_body
      return this.richEditorPlaceholder === body ? '' : html
    }
  },
  mounted () {
    const {title, rich_body: richBody} = this.chapter.attributes
    this.form = {
      title: title === this.$i18n.t('sections.title_placeholder') ? '' : title,
      body: richBody.body === this.richEditorPlaceholder ? '' : richBody.html,
    }
  },
  methods: {
    ...mapActions({
      setDialog: 'layout/setDialog',
      updateChapter: 'members/updateChapter',
      setSnackbar: 'layout/setSnackbar'
    }),
    openChapterDeleteDialog() {
      this.setDialog({
        title: 'Delete Chapter',
        component: 'ChapterDeleteDialog',
        data: {
          section: this.chapter,
          viewType: 'member'
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
          object_type: 'Kinship',
          object_id: ctx.member.id
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
    color: $tertiary;
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
        border-color: $medium-grey;
      }
    }
  }
}

</style>
