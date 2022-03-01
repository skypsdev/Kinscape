import {decamelizeKeys} from 'humps'

import Repository from './repository'

const resource = '/families'

export default {
  ownershipData (params = {}) {
    return Repository.get('/ownership_transfer/new', params)
  },
  familyStorageCount (params = {}) {
    return Repository.get('/storage_count', params)
  },
  ownershipDataPost (payload) {
    return Repository.post('/ownership_transfer', payload)
  },
  downloadContent (payload) {
    return Repository.post('/download_stories_zip', payload)
  },
  listFamilies (params = {}) {
    return Repository.get(resource, params)
  },
  getFamily (id, params = {}) {
    return Repository.get(`${resource}/${id}`, params)
  },
  quickListFamilies (params = {}) {
    return Repository.get(`${resource}/quick_list`, params)
  },
  createFamily (payload = {}) {
    return Repository.post(resource, payload)
  },
  updateFamily (familyId, payload) {
    return Repository.put(`${resource}/${familyId}`, payload)
  },
  removeFamily (familyId) {
    return Repository.delete(
      `${resource}/${familyId}`
    )
  },
  listFamiliesMember (id, type, params = {}) {
    if (type === 'defaults') {
      return Repository.get(`${resource}/${id}/kinships`, decamelizeKeys(params))
    } else {
      return Repository.get(`${resource}/${id}/invitations`, decamelizeKeys(params))
    }
  },
  sendInvitations (familyId, payload = {}) {
    return Repository.post(`${resource}/${familyId}/invitations`, { invitation: payload })
  },
  addOfflineMember(familyId, payload) {
    return Repository.post(`${resource}/${familyId}/offline_members`, payload)
  }
}
