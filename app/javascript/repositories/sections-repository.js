import Repository from './repository'

export default {
  listSections (publicationId, params = {}) {
    return Repository.get(`/publications/${publicationId}/sections`, params)
  },
  createSection (publicationId, payload) {
    return Repository.post(`/publications/${publicationId}/sections`, payload)
  },
  updateSection (publicationId, sectionId, payload) {
    return Repository.put(`/publications/${publicationId}/sections/${sectionId}`, payload)
  },
  deleteSection (publicationId, sectionId) {
    return Repository.delete(`/publications/${publicationId}/sections/${sectionId}`)
  }
}
