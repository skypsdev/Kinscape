import qs from 'qs'
import { decamelizeKeys } from 'humps'
import Repository from './repository'

const parent = 'vaults'
const resource = 'attachments'

export default {
  getVaultItems(id, params = {}) {
    return Repository.get(`/${parent}/${id}/items`, qs.stringify(decamelizeKeys(params), { arrayFormat: 'brackets' }))
  },
  getVault(id) {
    return Repository.get(`/${parent}/${id}`)
  },
  getVaults(params = {}) {
    return Repository.get(`/${parent}`, qs.stringify(decamelizeKeys(params), { arrayFormat: 'brackets' }))
  },
  getBox(vaultId, boxId, params = {}) {
    return Repository.get(`/${parent}/${vaultId}/boxes/${boxId}`, decamelizeKeys(params))
  },
  createAttachment(parentId, payload) {
    return Repository.post(`/${parent}/${parentId}/${resource}`, decamelizeKeys(payload))
  },
  updateAttachment(parentId, attachmentId, payload) {
    return Repository.put(
      `/${parent}/${parentId}/${resource}/${attachmentId}`,
      decamelizeKeys(payload)
    )
  },
  bulkDeleteAttachments(parentId, payload) {
    return Repository.delete(
      `/${parent}/${parentId}/items`,
      decamelizeKeys(payload)
    )
  },
  moveAttachments(parentId, boxId, ids) {
    return Repository.post(
      `/${parent}/${parentId}/${resource}/move`,
      { box_id: boxId, ids }
    )
  },
  copyAttachments({ vaultId, newVaultId, boxId, ids }) {
    return Repository.post(
      `/${parent}/${vaultId}/${resource}/copy`,
      { box_id: boxId, ids, new_vault_id: newVaultId }
    )
  },
}
