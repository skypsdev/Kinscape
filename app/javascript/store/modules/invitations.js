import { FamiliesRepository, InvitationsRepository } from '../../repositories';

const state = {
  receivedInvitations: [],
  sentInvitations: [],
  viewType: 'list'
}

const mutations = {
  SET_RECEIVED_INVITATIONS (state, receivedInvitations) {
    state.receivedInvitations = receivedInvitations
  },
  SET_SENT_INVITATIONS (state, sentInvitations) {
    state.sentInvitations = sentInvitations
  },
  SET_VIEW_TYPE(state, type) {
    state.viewType = type
  },
}

const actions = {
  async getAllInvitations({ commit }, { id, params = {} }) {
    try {
      let { data } = await InvitationsRepository.getReceivedInvitations(params)
      commit('SET_RECEIVED_INVITATIONS', data)

      let sent_data = await InvitationsRepository.getFamilyInvitations(id, params)
      commit('SET_SENT_INVITATIONS', sent_data.data)
    } catch (error) {
      console.error(error)
    }
  },
  setViewType({commit}, type) {
    commit('SET_VIEW_TYPE', type)
  },
  cancelInvitations({ dispatch }, invitationIds) {
    InvitationsRepository.cancelInvitations(invitationIds)
        .then(() => {
          dispatch('getAllInvitations')
          dispatch('layout/setSnackbar', 'Invitation canceled', { root: true })
        })
        .catch((error) => {
          dispatch('layout/setError', error, { root: true })
        })
  },
  async resendInvitations({ dispatch }, { invitationIds }) {
    try {
      await InvitationsRepository.resendInvitations(invitationIds)
      dispatch('layout/setSnackbar', 'Invitation resent', { root: true })
      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error, { root: true })
      return Promise.reject()
    }
  },
  sendInvitations({ dispatch }, { communityId, payload }) {
    FamiliesRepository.sendInvitations(communityId, payload)
        .then(() => {
            dispatch('getAllInvitations',communityId)
            dispatch('layout/setSnackbar', 'Invitations sent', { root: true })
        })
        .catch((error) => {
          dispatch('layout/setError', error, {root: true})
        })
  },
}

export default {
  namespaced: true,
  state,
  mutations,
  actions
}
