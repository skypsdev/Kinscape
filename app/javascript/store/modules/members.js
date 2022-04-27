import { FamiliesRepository, KinshipsRepository } from '../../repositories'
import ChaptersRepository from '../../repositories/chapters-repository'
import { camelizeKeys, decamelizeKeys } from 'humps'
import { Member } from '../../models/members'

const state = {
  viewType: 'grid',
  loading: false,
  error: false,
  members: [],
  member: new Member(),
  all: [],
  responseHeaders: new Headers(),
  chapters: [],
  activeChapter: ''
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
    state.members = [...state.members.filter((a) => a.id !== data.id), data]
  },
  ADD_RECORDS(state, data) {
    state.members = [...state.members, ...data]
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
  SET_ACTIVE_CHAPTER(state, chapter) {
    state.activeChapter = chapter
  },
  SET_TABLE_OF_CONTENT(state, links) {
    state.member.content.links = links
  },
  UPDATE_CHAPTERS(state, data) {
    state.chapters = data
  },
  SET_VIEW_TYPE(state, type) {
    state.viewType = type
  }
}

const actions = {
  getMyProfileByCommunityId({ commit }, {id, params={}}) {
    return new Promise((resolve, reject) => {
      commit('SET_LOADING', true)
      const model = { include: 'family', ...params }
      return KinshipsRepository.getKinshipByFamily(id, model)
        .then((res) => {
          res.data.included = res.included
          commit('SET_MEMBER', res.data)
          resolve(res.data)
        })
        .catch((err) => {
          commit('SET_ERROR', true)
          reject(err)
        })
        .finally(() => {
          commit('SET_LOADING', false)
        })
    })
  },
  setChangeStatus({ commit }, isChanged = true) {
    commit('SET_CHANGE_STATUS', isChanged)
  },
  setViewType({ commit }, type) {
    commit('SET_VIEW_TYPE', type)
  },
  // TODO remove redundant function
  async getCurrentMembersPage({ commit, getters }, payload) {
    commit('SET_LOADING', true)
    try {
      let requestParams = { page: getters.currentPage }
      let { data, headers } = await FamiliesRepository.listFamiliesMember(
        payload.id,
        payload.type,
        requestParams
      )
      const camelizedData = camelizeKeys(data)
      const members = camelizedData.map((member) => new Member(member))
      commit('SET_MEMBERS', members)
      commit('SET_RESPONSE_HEADERS', headers)
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async loadNext({ commit, getters }, payload = {}, params = {}) {
    if (getters.currentPage && getters.currentPage === getters.totalPages)
      return
    commit('SET_LOADING', true)
    try {
      let requestParams = { page: getters.currentPage + 1, ...params }
      let response = await FamiliesRepository.listFamiliesMember(
        payload.id,
        payload.type,
        requestParams
      )
      const camelizedData = camelizeKeys(response.data)
      const members = camelizedData.map((member) => new Member(member))
      commit('ADD_RECORDS', members)
      commit('SET_RESPONSE_HEADERS', response.headers)
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async getMember({ commit }, payload) {
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
        commit('comments/SET_COMMENTS', camelizeKeys(response.included), { root: true })
      }
      return response
    } catch (error) {
      console.error(error)
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  clearMember({ commit }) {
    commit('SET_MEMBER', new Member())
  },
  clearMembers({ commit }) {
    commit('SET_MEMBERS', [])
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  clearChapters({ commit }) {
    commit('UPDATE_CHAPTERS', [])
  },
  getTableOfContents({ commit, state }) {
    let optionsData = {
      object_id: state.member.id,
      object_type: 'Kinship'
    }
    try {
      ChaptersRepository.listTableOfContents(optionsData).then(
        (response) => {
          commit('SET_TABLE_OF_CONTENT', response.data.attributes.links)
        }
      )
    } catch (error) {
      console.log(error)
    }
  },
  async getChapters({ commit, state },options={}) {
    try {
      await ChaptersRepository.getSection({
        object_id: state.member.id,
        object_type: 'Kinship',
        ...options
      }).then((response) => {
        commit('UPDATE_CHAPTERS', response.data)
      })
    } catch (error) {
      console.error(error)
    }
  },
  async deleteChapter({ dispatch, state }, payload) {
    try {
      await ChaptersRepository.deleteSection(payload.id, {
        object_id: state.member.id,
        object_type: 'Kinship'
      }).then(() => {
        dispatch('getChapters')
        dispatch('getTableOfContents')
      })
    } catch (error) {
      console.error(error)
    }
  },
  createNewChapter({ commit, dispatch }, params) {
    commit('SET_LOADING', true)
    ChaptersRepository.createSection(params)
      .then(async (res) => {
        dispatch('getTableOfContents')
        await dispatch('getChapters')
        dispatch('setActiveChapter', res.data.id)
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
      .finally(() => {
        commit('SET_LOADING', false)
      })
  },
  updateChapter({ commit, dispatch }, chapter) {
    commit('SET_LOADING', true)
    ChaptersRepository.updateChapter(
      chapter.id,
      decamelizeKeys(chapter.form)
    )
      .then(() => {
        dispatch('setChangeStatus')
        dispatch('getTableOfContents')
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
      .finally(() => {
        commit('SET_LOADING', false)
      })
  },
  setActiveChapter({ commit }, chapter = '') {
    commit('SET_ACTIVE_CHAPTER', chapter.toString())
  },
  async updateMember({ commit, dispatch }, payload) {
    try {
      commit('SET_LOADING', true)
      const res = await KinshipsRepository.updateKinship(payload.id, decamelizeKeys(payload.form))
      commit('SET_MEMBER', { ...res.data })

      dispatch('setChangeStatus')

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  updateAvatar({ state, dispatch }, payload) {
    if (!payload) throw new Error('Empty payload')

    return dispatch('updateMember', {
      id: state.member.id,
      form: {
        avatar: payload
      }
    })
  }
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
    return (id) => state.members.find((a) => a.id === id)
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
