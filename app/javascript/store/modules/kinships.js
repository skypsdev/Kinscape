import { KinshipsRepository } from '../../repositories'
import ChaptersRepository from '../../repositories/chapters-repository'
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
    ChaptersRepository.getSection(parameters).then((response) => {
      commit('SET_CHAPTERS', response.data)
    }).catch((error) => {
      console.error(error)
      commit('SET_ERROR', true)
    }).finally(() => {
      commit('SET_LOADING', false)
    })
  },
  updateChapterList ({ commit }, data) {
    commit('UPDATE_CHAPTER_LIST', data)
  }
}

const getters = {
  getChapterList: (state) => {
    return state.chapterList
  },
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
