import { decamelizeKeys } from 'humps'
import Repository from './repository'

const resource = '/appreciations'

export default {
  createAppreciation (payload = {}) {
    return Repository.post(`${resource}`, decamelizeKeys(payload))
  },
  deleteAppreciation (appreciationId) {
    return Repository.delete(`${resource}/${appreciationId}`)
  }
}
