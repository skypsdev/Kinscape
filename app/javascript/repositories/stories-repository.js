import Repository from './repository'

const resource = '/stories'

export default {
  getStory (id, params = {}) {
    return Repository.get(`${resource}/${id}`, params)
  },
  listStories (params = {}) {
    return Repository.get(resource, params)
  },
  createStory (params) {
    return Repository.post(resource, params)
  },
  updateStory (id, payload = {}) {
    return Repository.put(`${resource}/${id}`, payload)
  },
  deleteStory (id) {
    return Repository.delete(`${resource}/${id}`)
  },
  duplicateStory (id) {
    return Repository.post(`${resource}/${id}/duplicate`)
  },
  notifyContribution (id) {
    return Repository.post(`${resource}/${id}/notify`)
  },
  listTableOfContents (id, payload = {}) {
    return Repository.get(`${resource}/${id}/chapter_links`, payload)
  },
  getConfig (id) {
    return Repository.get(`/${resource}/${id}/upload_config`)
  }
}
