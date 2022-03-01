import { FamiliesRepository, KinshipsRepository } from '../../repositories'
import FamilySectionsRepository from '../../repositories/family-sections-repository'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { Member } from "../../models/members"
import { DirectUpload } from '@rails/activestorage'

const state = {
  viewType: 'grid',
  loading: false,
  error: false,
  members: [],
  member: new Member(),
  all: [],
  responseHeaders: new Headers(),
  chapters: [],
  activeChapter: '',
}

const mutations = {
  SET_CHANGE_STATUS(state, isChanged = true) {
    state.member.isChanged = isChanged
  },
  SET_LOADING(state, data) {
    state.loading = data
  },
  SET_ERROR(state, data) {
    state.error = data
  },
  SET_MEMBERS(state, data) {
    state.members = data
  },
  ADD_RECORD(state, data) {
    state.members = [
      ...state.members.filter(a => a.id !== data.id),
      data
    ]
  },
  ADD_RECORDS(state, data) {
    state.members = [
      ...state.members,
      ...data
    ]
  },
  SET_RESPONSE_HEADERS(state, data) {
    state.responseHeaders = data
  },
  SET_CURRENT_PAGE(state, data) {
    state.currentPage = data
  },
  SET_TOTAL_PAGES(state, data) {
    state.totalPages = data
  },
  SET_MEMBER(state, member) {
    state.member = new Member(camelizeKeys(member))
  },
  SET_ACTIVE_CHAPTER (state, chapter) {
    state.activeChapter = chapter
  },
  SET_TABLE_OF_CONTENT (state, links) {
    state.member.content.links = links
  },
  UPDATE_CHAPTERS (state, data) {
    state.chapters = data
  },
  SET_VIEW_TYPE(state, type) {
    state.viewType = type
  },
}

const actions = {
  setChangeStatus({commit}, isChanged= true) {
    if (!state.member.isChanged) commit('SET_CHANGE_STATUS', isChanged)
  },
  setViewType({commit}, type) {
    commit('SET_VIEW_TYPE', type)
  },
  async getCurrentMembersPage ({ commit, getters }, payload) {
    commit('SET_LOADING', true)
    try {
      let requestParams = { page: getters.currentPage }
      let { data, headers } =
        await FamiliesRepository.listFamiliesMember(payload.id,
            payload.type,
            requestParams)
      const camelizedData = camelizeKeys(data)
      const members = camelizedData.map(member => new Member(member))
      commit('SET_MEMBERS', members)
      commit('SET_RESPONSE_HEADERS', headers)
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async loadNext ({ commit, getters }, payload = {}, params = {}) {
    if (getters.currentPage &&
       (getters.currentPage === getters.totalPages)) return
    commit('SET_LOADING', true)
    try {
      let requestParams = { page: getters.currentPage + 1, ...params }
      let response = await
      FamiliesRepository.listFamiliesMember(payload.id,
        payload.type,
        requestParams
      )
      const camelizedData = camelizeKeys(response.data)
      const members = camelizedData.map(member => new Member(member))
      commit('ADD_RECORDS', members)
      commit('SET_RESPONSE_HEADERS', response.headers)
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async getMember ({ commit }, payload) {
    commit('SET_LOADING', true)
    try {
      let response = {}
      response = await KinshipsRepository.getKinship(
          payload.id,
          payload.options
      )
      if (response.data) {
        response.data.included = response.included
        await commit('SET_MEMBER', response.data)
      }
      return response
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  clearMember ({ commit }) {
    commit('SET_MEMBER', new Member())
  },
  clearMembers ({ commit }) {
    commit('SET_MEMBERS', [])
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  getTableOfContents ({ commit, state }) {
    let optionsData = {
      object_id: state.member.id,
      object_type: 'Kinship'
    }
    try {
      FamilySectionsRepository.listTableOfContents(
          optionsData
      ).then(response => {
        commit('SET_TABLE_OF_CONTENT', response.data.attributes.links)
      })
    } catch (error) {
      console.log(error)
    }
  },
  async getChapters ({ commit, state }) {
    try {
      await FamilySectionsRepository.getSection(
          {
            object_id: state.member.id,
            object_type: 'Kinship'
          }
      )
          .then(response => {
            commit('UPDATE_CHAPTERS', response.data)
          })
    } catch (error) {
      console.error(error)
    }
  },
  async deleteChapter ({ dispatch, state }, payload) {
    try {
      await FamilySectionsRepository.deleteSection(
          payload.id,
          {
            object_id: state.member.id,
            object_type: 'Kinship'
          }
      )
          .then(() => {
            dispatch('getChapters')
            dispatch('getTableOfContents')
          })
    } catch (error) {
      console.error(error)
    }
  },
  createNewChapter({ commit, dispatch }, params) {
    commit('SET_LOADING', true)
    FamilySectionsRepository.createSection(params)
        .then(async (res)=> {
          dispatch('layout/setSnackbar', 'The chapter has been created', {root: true})
          dispatch('getTableOfContents')
          await dispatch('getChapters')
          dispatch('setActiveChapter', res.data.id)
        })
        .catch((error) => {
          dispatch('layout/setError', error, {root: true})
        })
        .finally(()=> {
          commit('SET_LOADING', false)
        })
  },
  updateChapter({commit, dispatch}, chapter) {
    commit('SET_LOADING', true)
    FamilySectionsRepository.updateChapter(chapter.id, decamelizeKeys(chapter.form))
        .then(()=> {
          dispatch('layout/setSnackbar', 'Saved', {root: true})
          dispatch('setChangeStatus')
          dispatch('getTableOfContents')
        })
        .catch((error) => {
          dispatch('layout/setError', error, {root: true})
        })
        .finally(() => {
          commit('SET_LOADING', false)
        })
  },
  setActiveChapter ({commit}, chapter = '') {
    commit('SET_ACTIVE_CHAPTER', chapter.toString())
  },
  updateMember({ commit, dispatch }, payload) {
    commit('SET_LOADING', true)
    KinshipsRepository.updateKinship(payload.id, decamelizeKeys(payload.form))
        .then((res)=> {
          commit('SET_MEMBER', {...res.data})
          dispatch('layout/setSnackbar', 'Saved', {root: true})
          dispatch('setChangeStatus')
        })
        .catch((error) => {
          dispatch('layout/setError', error, {root: true})
        })
        .finally(() => {
          commit('SET_LOADING', false)
        })
  },
  updateAvatar({commit, dispatch}, image) {
    commit('SET_LOADING', true)
    const upload = new DirectUpload(image, '/rails/active_storage/direct_uploads')
    upload.create((error, blob) => {
      if (error) {
        commit('SET_LOADING', false)
        throw new Error(`Direct upload failed: ${error}`)
      } else {
        dispatch('updateMember', {
          id: state.member.id,
          form: {
            avatar: blob.signed_id
          }
        })
      }
    })
  },
}

const getters = {
  isLoading: (state) => {
    return state.loading
  },
  isError: (state) => {
    return state.error
  },
  all: (state) => {
    return state.members
  },
  currentPage: (state) => {
    return parseInt(state.responseHeaders.get('Current-Page') || 0)
  },
  totalPages: (state) => {
    return parseInt(state.responseHeaders.get('Total-Pages') || 0)
  },
  load: (state) => {
    return id => state.members.find(a => a.id === id)
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
