import {decamelizeKeys} from 'humps'

import Repository from './repository'

const parent = '/vaults/'
const resource = '/boxes'

export default {
  createBox (parentId, payload) {
    return Repository.post(
      `${parent}${parentId}${resource}`,
      decamelizeKeys(payload)
    )
  },
  updateBox (parentId, boxId, payload) {
    return Repository.put(
      `${parent}${parentId}${resource}/${boxId}`,
      decamelizeKeys(payload)
    )
  },
  deleteBox (parentId, boxId) {
    return Repository.delete(`${parent}${parentId}${resource}/${boxId}`)
  }
}
