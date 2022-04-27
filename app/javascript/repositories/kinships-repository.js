import { decamelizeKeys } from 'humps'
import Repository from './repository'

const resource = '/kinships'

export function getKinship(id, params = {}) {
  return Repository.get(`${resource}/${id}`, params)
}
// TODO remove duplicated method app/javascript/repositories/families-repository.js -> listFamiliesMember()
export function listKinships (id,  params = {}) {
    return Repository.get(`/families/${id}/${resource}`, decamelizeKeys(params))
}
export function getKinshipByFamily(familyId, params = {}) {
  return Repository.get(`${resource}/by_family/${familyId}`, params)
}
export function updateKinship(id, payload) {
  return Repository.put(`${resource}/${id}`, payload)
}
export function kinshipDelete(id) {
  return Repository.delete(`${resource}/${id}`)
}
export function getKinshipID(payload) {
  return Repository.get(`${resource}/kinship_data`, payload)
}
export function updateRole(id, payload) {
  return Repository.put(`${resource}/${id}/role`, payload)
}
export function setOfflineMember(id, payload) {
  return Repository.put(`${resource}/${id}/offline_member`, payload)
}
export function notifyMembers (id, payload = {}) {
  return Repository.post(`${resource}/${id}`, payload)
}

export default {
  getKinship,
  getKinshipByFamily,
  updateKinship,
  kinshipDelete,
  getKinshipID,
  updateRole,
  setOfflineMember,
  notifyMembers
}
