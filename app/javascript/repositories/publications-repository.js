import qs from 'qs'
import { decamelizeKeys } from 'humps'
import Repository from './repository'

export default {
  getPublication (id, params = {}) {
    return Repository.get(`/publications/${id}`, decamelizeKeys(params))
  },
  createPublication (payload) {
    return Repository.post(`/publications`, payload)
  },
  deletePublication (id) {
    return Repository.delete(`/publications/${id}`)
  },
  listPublications (params = {}) {
    return Repository.get('/publications', qs.stringify(decamelizeKeys(params), {arrayFormat: 'brackets'}))
  },
  getCategories() {
    return Repository.get(`/categories`)
  },
  getSharableFamilies(id) {
    return Repository.get(`/publications/${id}/families`)
  }
}
