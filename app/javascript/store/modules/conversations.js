import {decamelizeKeys} from 'humps'
import {MessagesRepository} from '../../repositories'

export default {
  namespaced: true,
  state: {
    loading: false
  },
  mutations: {
    SET_LOADING (state, status) {
      state.loading = status
    }
  },
  actions: {
    sendMessage({commit, dispatch}, data) {
      commit('SET_LOADING', true)
      const snackbar = {
        messages: ['Message has been sent.']
      }
      MessagesRepository.sendMessage(decamelizeKeys(data)).then(() => {
        dispatch('layout/closeDialog', null, {root: true})
      }).catch(() => {
        snackbar.color = 'error'
        snackbar.messages = ['Failed to send your message.']
      }).finally(() => {
        dispatch('layout/setSnackbar', snackbar, {root: true})
        commit('SET_LOADING', false)
      })
    }
  }
};
