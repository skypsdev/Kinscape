import qs from 'qs'
import {decamelizeKeys} from 'humps'
import Repository from './repository'

const stories = '/stories'
const resource = '/publications'

export default {
  getPublication (id, params = {}) {
    return Repository.get(`${resource}/${id}`, decamelizeKeys(params))
  },
  createPublication (storyId, payload) {
    return Repository.post(`${stories}/${storyId}${resource}`, payload)
  },
  deletePublication (storyId, publicationId) {
    return Repository.delete(`${stories}/${storyId}${resource}/${publicationId}`)
  },
  listPublications (params = {}) {
    return Repository.get(resource, qs.stringify(decamelizeKeys(params), {arrayFormat: 'brackets'}))
  }
}
