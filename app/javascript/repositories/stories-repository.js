import Repository from './repository'

export default {
  createStory (params) {
    return Repository.post('/story', params)
  },
  updateStory (id, payload = {}) {
    return Repository.put(`/publications/${id}/story`, payload)
  },
  deleteStory (id) {
    return Repository.delete(`/publications/${id}/story`)
  },
  duplicateStory (id) {
    return Repository.post(`/publications/${id}/story/duplicate`)
  },
  notifyContribution (id, payload = {}) {
    return Repository.post(`/publications/${id}/story/notify`, payload)
  },
  listTableOfContents (id, payload = {}) {
    return Repository.get(`/publications/${id}/story/chapter_links`, payload)
  },
}
