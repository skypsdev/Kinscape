import Repository from './repository'

const resource = '/comments'

export default {
  createComment (payload) {
    return Repository.post(`${resource}`, payload)
  },
  deleteComment (commentId) {
    return Repository.delete(`${resource}/${commentId}`)
  }
}
