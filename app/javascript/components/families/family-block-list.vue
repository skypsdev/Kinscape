<template>
  <tr>
    <td class="img-center">
      <div class="custom-img-div">
        <img
          :src="cover_url?cover_url:require('../../assets/images/no_img.png')"
          class="custom-img"
          @error="imgPlaceholder"
        >
      </div>
    </td>

    <td>
      <div class="title-wrapper">
        <h4
          v-html="family.attributes.name"
        />
      </div>
    </td>

    <td>
      <router-link
        class="custom-button"
        :to="{ name: 'community', params: { id: family.id } }"
        :title="$i18n.t('families.show_title')"
      >
        {{ family.attributes.is_connected_by_current_user?'Edit':'Show' }}
      </router-link>
    </td>
  </tr>
</template>

<script>
import { mapActions, mapState} from 'vuex'
export default {
  props: {
    family: {
      type: Object,
      required: true
    }
  },
  data () {
    return {
      cover_url: this.family.attributes.cover_url
    }
  },
  computed: {
    ...mapState({
      currentUser: state => state.core.user
    }),
    isAuthor () {
      return this.currentUser.id === this.family.attributes.user.id.toString()
    }
  },
  methods: {
    ...mapActions([
      'successFlashMessage'
    ]),
    imgPlaceholder (e) {
      e.target.src = require('../../assets/images/no_img.png')
    }
  }
}
</script>

<style scoped>
.blocks .block {
  float: none !important;
  width: 60% !important;
}

.custom-img-div{
   min-width: 250px;
  max-width: 250px;
  height: 200px;
}

.custom-img-div .custom-img{
  min-width: 250px;
  max-width: 250px;
  height: 200px;
}

.custom-button{
  min-width: 200px !important;
  border: 1px solid;
  width: 150px !important;
  font-size: 22px;
  padding: 4px 53px;
  border-radius: 20px;
}

.img-center{
  text-align: -webkit-center !important;
}
</style>
