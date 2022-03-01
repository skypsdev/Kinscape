<template>
  <tr>
    <td>
      <div class="custom-img-div">
        <img
          :src="cover_url?cover_url:require('../../assets/images/no_img.png')"
          class="custom-img"
          @error="imgPlaceholder"
        >
      </div>
    </td>
    <td>
      {{ story.attributes.title?story.attributes.title:'-' }}
    </td>
    <td>
      {{ story.attributes.description?story.attributes.description:'-' }}
    </td>
    <td>
      {{ story.attributes.family_name?story.attributes.family_name:'-' }}
    </td>
    <td>
      {{
        story.attributes.sections_count
      }}
    </td>
    <td>
      {{
        story.attributes.contributors_count?
          story.attributes.contributors_count:'-'
      }}
    </td>
    <td>
      {{
        story.attributes.created_at?
          this.$i18n.l('date.formats.default',
                       story.attributes.created_at):'-'
      }}
    </td>
    <td>
      {{
        story.attributes.updated_at?
          this.$i18n.l('date.formats.default',
                       story.attributes.updated_at):'-'
      }}
    </td>
    <td>
      {{ story.attributes.date_as_text?story.attributes.date_as_text:'-' }}
    </td>
    <td>
      <div class="btn-divs">
        <table>
          <tr>
            <td>
              <router-link
                class="custom-button"
                :to="{ name: 'myLifeShowStory', params: { id: story.id } }"
              >
                <span>{{ $i18n.t("stories.action_button.open") }}</span>
              </router-link>
            </td>
            <td>
              <router-link
                v-if="isAuthor"
                :to="{ name: 'myLifeEditStory', params: { id: story.id } }"
                :title="$i18n.t('stories.action_button.edit_title')"
                class="edit-block edit-story custom-button"
              >
                <span>
                  {{ $i18n.t("stories.action_button.edit") }}
                </span>
              </router-link>

              <router-link
                v-else-if="story.attributes.can_collaborate_story"
                class="contribute-to-story custom-button"
                :title="$i18n.t('stories.action_button.contribute_title')"
                :to="{ name: 'myLifeEditStory', params: { id: story.id } }"
              >
                <span>
                  {{ $i18n.t("stories.action_button.contribute") }}
                </span>
              </router-link>
            </td>
          </tr>
          <tr>
            <td colspan="2">
              <router-link
                v-if="isAuthor || story.attributes.can_collaborate_story"
                class="comment-block comment-story custom-button"
                :title="$i18n.t('stories.action_button.comment_title')"
                :to="{ name: 'showMyLifeWithComments',
                       params: { id: story.id } }"
              >
                <span>
                  {{
                    $i18n.t('stories.comments',
                            { count: story.attributes.comments_count })
                  }}
                  | {{ story.attributes.appreciations_count }}
                  <i class="fa fa-smile-o" />
                </span>
              </router-link>
            </td>
          </tr>
          <tr>
            <td colspan="2">
              <a
                v-if="isAuthor"
                class="clone-story custom-button custom-copy"
                href=""
                @click.prevent="duplicateStory(story.id)"
              >
                <span>{{ $i18n.t("stories.action_button.copy") }}</span>
              </a>
            </td>
          </tr>
        </table>
      </div>
    </td>
  </tr>
</template>

<script>
import {mapActions, mapState} from 'vuex'
import { StoriesRepository } from '../../repositories'

export default {
  props: {
    story: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      cover_url: this.story.attributes.cover_url
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    isAuthor () {
      return this.currentUser.id === this.story.attributes.user_id.toString()
    }
  },
  methods: {
    ...mapActions({
      successFlashMessage: 'successFlashMessage'
    }),
    imgPlaceholder (e) {
      e.target.src = require('../../assets/images/no_img.png')
    },
    async duplicateStory (storyId) {
      try {
        const response = await StoriesRepository.duplicateStory(storyId)
        this.$router.push({
          name: 'myLifeEditStory',
          params: { id: response.data.id }
        })

        this.successFlashMessage(this.$i18n.t('stories.copied'))
      } catch (error) {
        console.error(error)
      }
    }
  }
}
</script>

<style scoped>
.btn-divs{
  display: flex;
  flex-direction: column;
  flex-wrap: wrap;
}

.custom-img-div{
  min-width: 175px;
  max-width: 175px;
  height: 110px;
}

.custom-img-div .custom-img{
  min-width: 175px;
  max-width: 175px;
  height: 110px;
}

.custom-button{
  min-width: 200px !important;
  border: 1px solid;
  width: 150px !important;
  font-size: 16px;
  padding: 4px 27px;
  border-radius: 20px;
  margin-top: 5px;
}

td {
  text-align: center;
}

.custom-copy{
  padding: 4px 74px !important;
}
</style>
