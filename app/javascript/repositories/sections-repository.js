import Repository from './repository'

const parent = '/stories/'
const resource = '/sections'

export default {
  listSections (storyId, params = {}) {
    return Repository.get(this.resourceUrl(storyId), params)
  },
  createSection (storyId, payload) {
    return Repository.post(this.resourceUrl(storyId), payload)
  },
  updateSection (storyId, sectionId, payload) {
    return Repository.put(this.resourceUrl(storyId, sectionId), payload)
  },
  deleteSection (storyId, sectionId) {
    return Repository.delete(this.resourceUrl(storyId, sectionId))
  },
  resourceUrl (parentId, resourceId) {
    let resourceUrl = `${parent}${parentId}${resource}`
    if (resourceId) resourceUrl += `/${resourceId}`
    return resourceUrl
  }
}
