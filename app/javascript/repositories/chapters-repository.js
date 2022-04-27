import Repository from './repository'

const resource = '/chapters/'

export default {
  getSection (payload) {
    return Repository.get(resource, payload)
  },
  createSection (payload) {
    return Repository.post(resource, payload)
  },
  deleteSection (chapterId, payload) {
    return Repository.delete(`${resource}${chapterId}`, payload)
  },
  updateChapter (chapterId, payload) {
    return Repository.patch(`${resource}${chapterId}?object_id=${payload.object_id}`, payload)
  },
  listTableOfContents (payload = {}) {
    return Repository.get('/table_content_list', payload)
  }
}
