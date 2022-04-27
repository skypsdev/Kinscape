import { decamelizeKeys } from 'humps'
import Vue from 'vue'

import { MessagesRepository } from '@/repositories'

export default {
  namespaced: true,
  state: {
    loading: false,
    recipients: {
      families: [],
      members: []
    }
  },
  mutations: {
    SET_LOADING(state, status) {
      state.loading = status
    },
    SET_RECIPIENTS(state, { key, data }) {
      Vue.set(state.recipients, key, data)
    }
  },
  actions: {
    sendMessage({ commit, dispatch }, data) {
      commit('SET_LOADING', true)
      const snackbar = {
        messages: ['Message has been sent.']
      }
      MessagesRepository.sendMessage(decamelizeKeys(data)).then(() => {
        dispatch('layout/closeDialog', null, { root: true })
      }).catch(() => {
        snackbar.color = 'error'
        snackbar.messages = ['Failed to send your message.']
      }).finally(() => {
        dispatch('layout/setSnackbar', snackbar, { root: true })
        commit('SET_LOADING', false)
      })
    },
    async getRecipients({ commit, dispatch }) {
      try {
        commit('SET_LOADING', true)
        const { data: families, included: members } = await MessagesRepository.getRecipients()

        commit('SET_RECIPIENTS', { key: 'families', data: families })
        commit('SET_RECIPIENTS', { key: 'members', data: members })
        
      } catch (error) {
        dispatch('layout/setError', error, { root: true })
      } finally {
        commit('SET_LOADING', false)
      }
    }
  }
};
