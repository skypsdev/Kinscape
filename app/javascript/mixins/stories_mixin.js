import { StoriesRepository } from '../repositories'

export const storiesMixin = {
  methods: {
    async createStory () {
      try {
        const response =
          await StoriesRepository.createStory()
        if (this.$router) {
          if (this.$route.name === 'myStories') {
            this.$router.push({
              name: 'myLifeEditStory', params: { id: response.data.id }
            })
          } else {
            this.$router.push({
              name: 'editStory', params: { id: response.data.id }
            })
          }
        } else {
          window.location.href = '/stories/' + response.data.id + '/edit'
        }
      } catch (error) {
        console.error(error)
      }
    }
  }
}
