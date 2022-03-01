import {decamelizeKeys} from 'humps'

import Repository from './repository'
const parent = '/publications'
const resource = '/appreciations'

export default {
  createAppreciation (publicationId, payload) {
    return Repository.post(`${parent}/${publicationId}${resource}`, decamelizeKeys(payload))
  },
  deleteAppreciation (publicationId, appreciationId) {
    return Repository.delete(`${parent}/${publicationId}${resource}/${appreciationId}`)
  }
}
