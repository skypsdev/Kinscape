import Repository from './repository'

const parent = '/publications/'
const resource = '/comments'

export default {
  createComment (publicationId, payload) {
    return Repository.post(this.resourceUrl(publicationId), payload)
  },
  deleteComment (publicationId, commentId) {
    return Repository.delete(this.resourceUrl(publicationId, commentId))
  },
  resourceUrl (parentId, resourceId) {
    let resourceUrl = `${parent}${parentId}${resource}`
    if (resourceId) resourceUrl += `/${resourceId}`
    return resourceUrl
  }
}
