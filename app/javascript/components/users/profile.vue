<template>
  <div class="legacy-styles">
    <div
      id="user-profile"
      class="page-container align-center main-profile-div"
    >
      <div
        v-if="!isLoading"
        class="w-100"
      >
        <div
          v-if="kinship"
          class="my-life main-profile-div"
        >
          <section
            v-if="kinship && isKinshipWatched"
            id="profile_sidebar"
            :class="{'profile custom-section':!editMode}"
          >
            <profile-details
              v-if="!editMode"
              :user="user"
              :kinship="kinship"
              :edit-mode="editMode"
            />
          </section>
          <div
            v-if="editMode"
            class="profile-wrapper no-profile-information"
          >
            <profile-details
              :user="user"
              :kinship="kinship"
              :edit-mode="editMode"
            />
  
            <TableOfChapter
              :toc-links="tocLinks"
              :chapters="chapters"
              :is-edit-mode="editMode"
              :family-id="kinship.attributes.family_id"
              :type-object="'Kinship'"
              :kinship-id="kinship.id"
            />
          </div>
          <div
            v-if="editMode"
            class="w-100"
          >
            <!-- <rich-editor
              class="set-editor"
              :class="{'disable-btn':
                !kinship.attributes.is_current_user_connector &&
                kinship.attributes.user_id != currentUser.id}"
              :current-user="currentUser"
              :value="kinship.attributes.rich_profile.body"
              @editor-change="assignContentAndSave"
            /> -->
  
            <div
              v-if="chapters.length>0"
              class="content-wrapper pt-0"
            >
              <div
                v-for="c in chapters"
                :key="c.id"
                class="chapter_data"
              >
                <div
                  v-if="removePromptVisible && c.id === chapter.id"
                  class="remove-section-wrapper"
                >
                  <div class="prompt">
                    {{ $i18n.t('placeholders.section.remove') }}
                  </div>
                  <div class="actions">
                    <button
                      class="btn-cancel hoverBlue"
                      @click="hideRemovePrompt()"
                    >
                      {{ $i18n.t('placeholders.section.remove_deny') }}
                    </button>
                    <button
                      class="btn-cancel bgRed"
                      @click="deleteChapter(kinship)"
                    >
                      {{ $i18n.t('placeholders.section.remove_approve') }}
                    </button>
                  </div>
                </div>
  
                <div class="add-content-wrapper">
                  <div class="add-content">
                    <a
                      class="add-chapter-btn"
                      title="Add Chapter"
                      @click="onAddChapter(
                        family,
                        c.attributes.position,
                        chapters
                      )"
                    >
                      Add Chapter
                    </a>
                  </div>
                </div>
  
                <div class="chapter-edit-container">
                  <div
                    v-if="!removePromptVisible"
                    class="edit-actions"
                  >
                    <a
                      class="remove-section"
                      title="Remove Content Area"
                      @click="showRemovePrompt(c)"
                    >
                      <i class="fa fa-trash-o" />
                    </a>
                  </div>
  
                  <input
                    id="sectionTitle"
                    :value="c.attributes.title ===
                      $i18n.t('sections.title_placeholder')
                      ? '' : c.attributes.title"
                    :placeholder="(c.attributes.title ===
                      $i18n.t('sections.title_placeholder') ||
                      c.attributes.title === '')
                      ? $i18n.t('sections.title_placeholder') : ''"
                    type="text"
                    class="inputField"
                    @change="UpdateTitle($event, c)"
                  >
  
                  <rich-editor
                    :input="'chapter_content_' + c.id"
                    :current-user="currentUser"
                    :value="chapter_body(c)"
                    :direct-upload-path="directUploadPath"
                    :blob-path="blobPath"
                    :class="{'disable-btn':
                      !kinship.attributes.is_current_user_connector &&
                      kinship.attributes.user_id !== currentUser.id}"
                    @editor-change="assignContentAndSave($event, c)"
                  />
                </div>
              </div>
            </div>
  
            <div class="add-content-wrapper">
              <div class="add-content add-content-bottom">
                <a
                  class="add-chapter-btn"
                  title="Insert New Content"
                  @click="onAddChapter(family, chapters.length, chapters)"
                >
                  Add Chapter
                </a>
              </div>
            </div>
          </div>
          <!-- <div
            v-if="!editMode"
            class="no-profile-information content-break"
            v-html="kinship.attributes.rich_profile.html"
          /> -->
          <div
            v-if="!editMode"
            class="no-profile-information text-wrap chapter-table-design"
          >
            <TableOfChapter
              class="align-self-start"
              :toc-links="tocLinks"
              :chapters="chapters"
              :is-edit-mode="editMode"
              :family-id="kinship.attributes.family_id"
              :type-object="'Kinship'"
              :kinship-id="kinship.id"
            />
            <div
              v-if="chapters.length>0"
              class="content-wrapper pt-0"
            >
              <ChapterViewer
                v-for="c in chapters"
                :key="c.id"
                :section="c"
              />
            </div>
          </div>
          <div
            v-if="!editMode && kinship.relationships.chapters.data == ''"
            class="no-profile-information text-wrap"
          >
            This Community Member has no shared information
          </div>
        </div>
        <section
          v-if="!kinship"
          class="page-blocks-holder"
        >
          <div class="message-container">
            <div class="inner">
              <p class="message">
                You're not a member of any Community. My Life profiles are meant
                to be shared with Communities. Click Add Community to create
                your first Community or ask another Community member
                on Kinscape to invite you.
              </p>
              <a href="/communities/new">Add Community</a>
            </div>
          </div>
        </section>
      </div>
    </div>
  </div>
</template>

<script>
import {mapGetters, mapActions, mapState} from 'vuex'

import FamilySectionsRepository from
  '../../repositories/family-sections-repository'

import RichEditor from '../shared/rich-editor'
import ProfileDetails from './profile-details'
import TableOfChapter from '../shared/table-of-chapter.vue'
import ChapterViewer from '../shared/chapter-viewer'

export default {
  components: {
    RichEditor,
    ProfileDetails,
    TableOfChapter,
    ChapterViewer
  },
  data () {
    return {
      chapter: '',
      chapters: [],
      removePromptVisible: false,
      title: '',
      placeholder: '',
      kinshipId: null,
      editMode: false,
      editingKinship: this.kinship,
      isKinshipWatched: false,
      // savingStatus: 'initial',
      blobPath: '/rails/active_storage/blobs/signed_id/filename',
      directUploadPath: '/rails/active_storage/direct_uploads'
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user,
      // TODO-SELECTED-FAMILY-ID: use correct family id
      chosenFamilyId: state => state.families.simpleList.families[0]?.id
    }),
    ...mapGetters({
      loadKinship: 'kinships/load',
      isLoading: 'kinships/isLoading',
      isError: 'kinships/isError',
    }),
    kinship () {
      return this.loadKinship(this.kinshipId)
    },
    user () {
      return this.kinship.included.find(k => k.type === 'user')
    },
    isCurrentUser () {
      return this.currentUser.id === this.user.id
    },
    canManage () {
      return this.isCurrentUser
    },
    tocLinks () {
      return this.kinship.attributes.links
    }
  },
  watch: {
    '$route': 'fetchKinship',
    'chosenFamilyId': 'fetchKinship'
  },
  async mounted () {
    await this.fetchKinship()
    await this.getChapters()
  },
  methods: {
    ...mapActions({
      findKinship: 'kinships/findRecord',
      updateChapterList: 'kinships/updateChapterList'
    }),
    chapterList () {
      let optionsData = {
        object_id: this.kinship.id,
        object_type: 'Kinship'
      }
      try {
        FamilySectionsRepository.listTableOfContents(
          optionsData
        )
          .then(response => {
            this.updateChapterList(response.data.attributes.links)
          })
      } catch (error) {
        console.log(error)
      }
    },
    async onAddChapter (family, chapter, chapters) {
      await this.createChapter(family, chapter, chapters)
      await this.chapterList()
    },
    getChapters () {
      try {
        FamilySectionsRepository.getSection(
          {
            familyId: this.kinship.attributes.family_id,
            kinshipId: this.kinship.id,
            type: 'Kinship'
          }
        )
          .then(response => {
            this.chapters = response.data
          })
      } catch (error) {
        console.error(error)
      }
    },
    hideRemovePrompt () {
      this.removePromptVisible = false
    },
    showRemovePrompt (chapter) {
      this.chapter = chapter
      this.removePromptVisible = true
    },
    chapter_body (chapter) {
      var value = chapter.attributes.rich_body.body ===
                  '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
        ? '' : chapter.attributes.rich_body.body

      return value
    },
    UpdateTitle (event, c) {
      c.attributes.title = event.target.value
      this.assignContentAndSave('', c)
    },
    deleteChapter: async function () {
      try {
        await FamilySectionsRepository.deleteSection(
          this.chapter.id,
          {
            familyId: this.kinship.attributes.family_id,
            kinshipId: this.kinship.id,
            type: 'Kinship'
          }
        )
          .then(() => {
            this.removePromptVisible = false
            this.chapterList()
            this.getChapters()
            // this.$router.go(0)
          })
      } catch (error) {
        console.error(error)
      }
    },
    chapterLoder () {
      return this.chapters.slice(0).sort((a, b) => {
        return a.attributes.position - b.attributes.position
      })
    },
    createChapter: async function (family, position, chapters) {
      var isLastSection = false
      if (chapters.length > 0 && position === chapters.length) {
        isLastSection = true
        this.sectionLoader(position, chapters)
      }
      const params = {
        familyId: this.kinship.attributes.family_id,
        kinshipId: this.kinship.id,
        type: 'Kinship',
        media_type: 'text',
        position: position,
        title: this.$i18n.t('sections.title_placeholder'),
        rich_body: '<p>' + this.$i18n.t('sections.body_placeholder') + '</p>'
      }
      try {
        const response =
          await FamilySectionsRepository.createSection(params)
        if (isLastSection) {
          this.sectionCreated(response.data, chapters)
        } else {
          if (this.chapterLoder === undefined) {
            // this.$emit('sectionCreated', response.data)
          } else {
            this.sectionCreated(response.data, chapters, isLastSection)
          }
        }
      } catch (error) {
        console.error(error)
      }
    },
    sectionLoader (position, chapters) {
      const sectionLoader = {
        id: 0,
        loader: true,
        attributes: { position: position }
      }
      chapters.splice(position, 0, sectionLoader)
    },
    elementSelector (index) {
      return '.content-wrapper .chapter_data:nth-child(' + (index + 1) + ')'
    },
    sectionCreated (section, chapters, isLastSection = true) {
      var length = 0
      if (isLastSection) {
        length = 1
      }
      chapters.splice(section.attributes.position, length, section)
      chapters.forEach((s, i) => { s.attributes.position = i })

      const selector = this.elementSelector(section.attributes.position)
      // while (!document.querySelector(selector)) {
      //   // TODO: Need to work on scroll
      //   this.loadSections(this.family.id)
      // }
      this.$scrollTo(selector, 500, { offset: -80 })
    },
    async fetchKinship () {
      this.isKinshipWatched = false
      let params = {
        options: {
          include: 'family'
        }
      }

      if (this.$route.params.id) {
        params['id'] = this.$route.params.id.toString()
      } else {
        params['familyId'] = this.chosenFamilyId
      }

      try {
        const { data } = await this.findKinship(params)
        if (data === false) {
          this.$router.push({ path: '/stories?unauthorized=true' })
        } else {
          this.kinshipId = data.id
          this.isKinshipWatched = true
        }
      } catch (error) {
        console.error(error)
      }
    },
    assignContentAndSave (event, chapter) {
      if (event) {
        if (!Array.from(event.target.childNodes).map(node => {
          return node.localName
        }).includes('h1')) {
          let html = event.target.inputElement.value
          html = html.replace('<div><!--block--><br></div>', '')
          event.target.inputElement.value = html
        }
        if (chapter.attributes.rich_body.body ===
          event.target.inputElement.value) return
        chapter.attributes.rich_body.body = event.target.inputElement.value
      }
      chapter.attributes.title = (chapter.attributes.title === '')
        ? this.title : chapter.attributes.title

      this.$set(chapter, 'rich_body', chapter.attributes.rich_body)
      this.save(chapter)
    },
    save (chapter) {
      chapter.attributes.type = 'Kinship'
      chapter.attributes.familyId = this.kinship.attributes.family_id
      chapter.attributes.kinshipId = this.kinship.id

      if (this.timeout) clearTimeout(this.timeout)
      this.timeout = setTimeout(async () => {
        this.$emit('update:savingStatus', 'started')
        let id = chapter.id
        let att = chapter.attributes
        try {
          await FamilySectionsRepository.updateChapter(id, att)
          this.chapterList()
          this.$emit('update:savingStatus', 'finished')
        } catch (error) {
          this.$emit('update:savingStatus', 'failed')
          console.log(error)
        }
      }, 500)
    }
  }
}
</script>

<style lang="scss" scoped>
  .disable-btn {
    cursor: not-allowed;
    pointer-events: none;
    opacity: 0.4;
  }

  .profile-wrapper {
  }

  .no-profile-information {
    padding: 15px;
  }

  .edit-mode-wrapper {
    margin-bottom: 15px;
    text-align: center;

    a {
      max-width: 300px;
      margin: auto;
    }
  }

  @media (max-width: 760px) {
    .my-life {
      display: block;
    }
  }

  .setUserFamily {
    display: flex;
    justify-content: center;
    width: 100%;
  }
</style>

<style lang="scss">
  #user-profile {
    width: 100%;
    padding-top: 59px;
  }

  .trix-content {
    padding-top: 15px;
  }

  .set-editor {
    margin-left:70px !important;
    // margin-top:120px !important;
  }

  .custom-section{
    width: 100% !important;
    border-right: none !important;
  }
  .main-profile-div {
    flex-wrap: wrap !important;
  }

  .my-life{
    justify-content: center;
  }
</style>

<style scoped>
  .hoverBlue:hover{
    background-color: #8B78FE !important;
    color:  white !important;
  }
  .bgRed {
    background-color: tomato !important;
    color:  white !important;
  }
  .bgRed:hover {
    background-color: #ff8484 !important;
    color:  white !important;
  }

 .remove-section-wrapper{
    background: rgba(255, 217, 217, 0.75);
    border: 4px solid #ff6a6a;
    border-radius: 10px;
    text-align: center;
    width: 85%;
    height: 175px;
  }
  .btn-cancel{
    transition: all .15s linear;
    border-radius: 3px;
    border: 1px solid #8c98a8;
    display: inline-block;
    font-weight: 300;
    letter-spacing: 1px;
    line-height: normal;
    text-align: center;
    text-transform: none;
    cursor: pointer;
    padding: 0.4em;
    background: transparent;
    color: #8c98a8;
    margin: 8px;
    width: 260px;
  }
  .prompt{
    margin-top: 45px;
  }
  .add-content-wrapper{
    margin-top: 85px !important;
  }
  .chapter-table-design{
    display: flex;
    flex-direction: column;
    width: 100%;
  }
</style>
