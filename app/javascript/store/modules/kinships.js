import { KinshipsRepository } from '../../repositories'
import FamilySectionsRepository from '../../repositories/family-sections-repository'
import { Member } from "../../models/members";

const state = {
  loading: false,
  kinshipId: null,
  all: [],
  chapters: [],
  error: false,
  included: [],
  chapterList: [],
  member: new Member(),
}

const mutations = {
  SET_KINSHIP_ID (state, id) {
    state.kinshipId = id
  },
  SET_CHAPTERS (state, chapters) {
    state.chapters = chapters
  },
  UPDATE_CHAPTER_LIST (state, data) {
    state.chapterList = data
  },
  SET_LOADING (state, data) {
    state.loading = data
  },
  SET_ERROR (state, data) {
    state.error = data
  },
  ADD_RECORD (state, data) {
    state.all = [
      ...state.all.filter(a => a.id !== data.id),
      data
    ]
  },
  DELETE_KINSHIP (state, kinshipId) {
    state.all = state.all.filter((kinship) => {
      return kinship.id !== kinshipId
    })
  }
}

const actions = {
  getKinshipByFamily ({ commit, dispatch }, familyId) {
    commit('SET_LOADING', true)
    const params = { include: 'family' }
    KinshipsRepository.getKinshipByFamily(familyId, params).then((res) => {
      commit('SET_KINSHIP_ID', res.data.id)
      res.data.included = res.included
      commit('ADD_RECORD', res.data)
      dispatch('getKinshipSection', { kinshipId: res.data.id })
    }).catch(() => {
      commit('SET_ERROR', true)
    })
  },
  getKinshipSection ({ commit }, { kinshipId }) {
    const parameters = {
      object_id: kinshipId,
      object_type: 'Kinship'
    }
    FamilySectionsRepository.getSection(parameters).then((response) => {
      commit('SET_CHAPTERS', response.data)
    }).catch((error) => {
      console.error(error)
      commit('SET_ERROR', true)
    }).finally(() => {
      commit('SET_LOADING', false)
    })
  },
  async findRecord ({ commit }, payload) {
    commit('SET_LOADING', true)
    try {
      let response = {}
      if (payload.familyId) {
        response = await KinshipsRepository.getKinshipByFamily(
          payload.familyId,
          payload.options
        )
      } else {
        response = await KinshipsRepository.getKinship(
          payload.id,
          payload.options
        )
      }
      if (response.data) {
        response.data.included = response.included
        commit('ADD_RECORD', response.data)
      }
      return response
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async deleteKinship ({ commit }, kinshipId) {
    commit('SET_LOADING', true)
    try {
      await KinshipsRepository.kinshipDelete(kinshipId)
      commit('DELETE_KINSHIP', kinshipId)
      return true
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  updateChapterList ({ commit }, data) {
    commit('UPDATE_CHAPTER_LIST', data)
  }
}

const getters = {
  getChapterList: (state) => {
    return state.chapterList
  },
  isLoading: (state) => {
    return state.loading
  },
  isError: (state) => {
    return state.error
  },
  all: (state) => {
    return state.all
  },
  load: (state) => {
    return id => state.all.find(a => a.id === id)
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
