import { CommentsRepository } from '../../repositories'
import {camelizeKeys, decamelizeKeys} from 'humps'

const state = {
  loading: false,
  allComments: []
}

const mutations = {
  SET_LOADING (state, data) {
    state.loading = data
  },
  SET_COMMENTS (state, allComments) {
    state.allComments = allComments
  },
  ADD_COMMENT (state, comment) {
    state.allComments.push(comment)
  },
  REMOVE_COMMENT (state, comment) {
    state.allComments = state.allComments.filter(r => r.id !== comment.id)
  }
}

const actions = {
  addComment ({ commit, dispatch }, params) {
    commit('SET_LOADING', true)
    CommentsRepository.createComment(
      params.publicationId, decamelizeKeys(params.body))
      .then((res) => {
        commit('ADD_COMMENT', camelizeKeys(res.data))
      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(() => {
        commit('SET_LOADING', false)
      })
  },
  deleteComment ({ commit, dispatch }, payload) {
    commit('SET_LOADING', true)
    CommentsRepository.deleteComment(payload.parentId, payload.id)
      .then(() => {
        commit('REMOVE_COMMENT', payload)
      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(() => {
        commit('SET_LOADING', false)
      })
  }
}

export default {
  namespaced: true,
  state,
  actions,
  mutations
}
