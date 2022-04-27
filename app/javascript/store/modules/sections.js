import { SectionsRepository } from '../../repositories'

const state = {
  loading: false,
  error: false,
  all: [],
  responseHeaders: new Headers()
}

const getters = {
  isLoading: (state) => {
    return state.loading
  },
  isError: (state) => {
    return state.error
  },
  all: (state) => {
    return state.all
  },
  currentPage: (state) => {
    return parseInt(state.responseHeaders.get('Current-Page') || 0)
  },
  totalPages: (state) => {
    return parseInt(state.responseHeaders.get('Total-Pages') || 0)
  },
  hasMorePages: (state, getters) => {
    const {currentPage, totalPages} = getters
    return currentPage && currentPage < totalPages
  },
  load: (state) => {
    return id => state.all.find(a => a.id === id)
  }
}

const actions = {
  async loadAll ({ commit }, publicationId, params = {}) {
    commit('setLoading', true)
    try {
      let { data, headers } =
        await SectionsRepository.listSections(publicationId, params)
      commit('loadAll', data)
      commit('setResponseHeaders', headers)
    } catch (error) {
      console.error(error)
      commit('setError', true)
    } finally {
      commit('setLoading', false)
    }
  },
  async loadNext ({ commit, getters }, {id, params = {}}) {
    if (getters.currentPage && getters.currentPage === getters.totalPages) return
    commit('setLoading', true)
    try {
      let requestParams = { page: getters.currentPage + 1, ...params }
      let { data, headers } =
        await SectionsRepository.listSections(id, requestParams)
      commit('addRecords', data)
      commit('setResponseHeaders', headers)
    } catch (error) {
      console.error(error)
      commit('setError', true)
    } finally {
      commit('setLoading', false)
    }
  },
  async loadCurrentPage ({ commit, getters }, publicationId, params = {}) {
    commit('setLoading', true)
    try {
      let requestParams = { page: getters.currentPage || 1, ...params }
      let { data, headers } =
        await SectionsRepository.listSections(publicationId, requestParams)
      commit('addRecords', data)
      commit('setResponseHeaders', headers)
    } catch (error) {
      console.error(error)
      commit('setError', true)
    } finally {
      commit('setLoading', false)
    }
  },
  clearSections ({ commit }) {
    commit('loadAll', [])
    commit('setResponseHeaders', new Headers())
  },
  deleteSection ({ commit }, section) {
    commit('deleteSection', section.id)
  }
}

const mutations = {
  setLoading (state, data) {
    state.loading = data
  },
  setError (state, data) {
    state.error = data
  },
  loadAll (state, data) {
    state.all = data
  },
  addRecords (state, data) {
    state.all = [
      ...state.all,
      ...data
    ].filter((v,i,a)=>a.findIndex(t=>(t.id === v.id))===i)
  },
  deleteSection (state, sectionId) {
    state.all = state.all.filter((section) => {
      return section.id !== sectionId
    })
  },
  setResponseHeaders (state, data) {
    state.responseHeaders = data
  },
  setCurrentPage (state, data) {
    state.currentPage = data
  },
  setTotalPages (state, data) {
    state.totalPages = data
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
