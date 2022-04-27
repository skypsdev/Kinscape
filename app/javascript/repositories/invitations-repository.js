import { decamelizeKeys } from 'humps'
import Repository from './repository'

const INVITATIONS_URL = '/invitations/'
const FAMILIES_URL = '/families/'

export default {
    showInvitation(invitationId) {
        return Repository.get(`${INVITATIONS_URL}${invitationId}`)
    },
    createInvitation(familyId, invitationId, payload) {
        return Repository.post(
            `${FAMILIES_URL}${familyId}${INVITATIONS_URL}/${invitationId}`,
            payload
        )
    },
    updateInvitation(invitationId, payload) {
        return Repository.patch(
            `${INVITATIONS_URL}/${invitationId}`,
            payload
        )
    },
    cancelInvitations(invitationIds) {
        return Repository.delete(INVITATIONS_URL, { ids: invitationIds })
    },
    resendInvitations(invitationIds) {
        return Repository.post('/invitations/resend', { ids: invitationIds })
    },
    getReceivedInvitations(params) {
        return Repository.get('/received_invitations',decamelizeKeys(params))
    },
    getFamilyInvitations(familyId,params) {
        return Repository.get(`/families/${familyId}/invitations`,decamelizeKeys(params))
    }
}
