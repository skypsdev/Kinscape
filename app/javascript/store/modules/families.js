import { camelizeKeys, decamelizeKeys } from 'humps'

import { FamiliesRepository, InvitationsRepository, PublicationsRepository, AppreciationsRepository } from '../../repositories'

import ChaptersRepository from "../../repositories/chapters-repository";

import { Community } from "../../models/communities";

const state = {
  community: new Community(),
  chapters: [],
  activeChapter: '',
  loading: false,
  error: false,
  // Family information from the list endpoint
  simpleList: {
    families: [],
    members: []
  },
  sharableFamilies: [],
  listed: [],
  // Family information with extended information from paginated endpoint
  all: [],
  responseHeaders: new Headers(),
  isAdmin: false,
  viewType: 'grid',
  filters: {
    search: {
      query: ''
    }
  },
  invitation: {},
}

const mutations = {
  SET_SHARABLE_FAMILIES(state, payload) {
    state.sharableFamilies = payload
  },
  SET_COMMUNITY(state, payload) {
    state.community = payload
  },
  SET_ACTIVE_CHAPTER(state, chapter) {
    state.activeChapter = chapter
  },
  SET_TABLE_OF_CONTENT(state, links) {
    state.community.content.links = links
  },
  SET_COMMUNITY_CHANGE_STATUS(state, isChanged = true) {
    state.community.isChanged = isChanged
  },
  UPDATE_CHAPTERS(state, data) {
    state.chapters = data
  },
  UPDATE_IS_ADMIN(state, data) {
    state.isAdmin = data
  },
  SET_LOADING(state, data) {
    state.loading = data
  },
  LOAD_QUICK_LIST(state, { data, included }) {
    state.simpleList.families = data.filter((item) => item.type === 'family')
    state.simpleList.members = included.filter((item) => item.type === 'kinship')
  },
  RESET(state) {
    state.all = []
  },
  ADD_RECORD(state, data) {
    state.all = [
      ...state.all.filter(a => a.id !== data.id),
      data
    ]
  },
  ADD_RECORDS(state, data) {
    state.all = [
      ...state.all,
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
  SET_COMMUNITIES_VIEW_TYPE(state, type) {
    state.viewType = type
  },
  SET_COMMUNITIES_SEARCH(state, search) {
    state.filters.search = search
  },
  SET_INVITATION(state, invitation) {
    state.invitation = invitation
  }
}

const actions = {
  async getCommunity({ commit, dispatch }, payload) {
    commit('SET_LOADING', true)
    try {
      let { data, included } = await FamiliesRepository.getFamily(
          payload.id,
          {...payload.options}
      )
      const community = {
        ...camelizeKeys(data)
      }

      commit('SET_COMMUNITY', new Community(community))
      commit('comments/SET_COMMENTS', camelizeKeys(included), { root: true })
    } catch (error) {
      console.error(error)
      dispatch('layout/setError', error, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async loadQuickList({ commit, dispatch }, params = {}) {
    try {
      commit('SET_LOADING', true)
      const res = await FamiliesRepository.quickListFamilies(params)
          const { data, included } = camelizeKeys(res)
          commit('LOAD_QUICK_LIST', { data, included })
          // commit('SET_RESPONSE_HEADERS', headers)
          return Promise.resolve()
        } catch (error) {
          dispatch('layout/setError', error, { root: true })
          return Promise.reject()
        } finally {
          commit('SET_LOADING', false)
    }
  },
  async getSharableFamilies({ commit, dispatch }, publicationId) {
    try {
      commit('SET_LOADING', true)
      const res = await PublicationsRepository.getSharableFamilies(publicationId)
      const { data } = camelizeKeys(res)

      commit('SET_SHARABLE_FAMILIES', data)

    } catch (error) {
      dispatch('layout/setError', error, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async loadNext({ commit, getters, dispatch }, params = {}) {
    if (getters.currentPage &&
      (getters.currentPage === getters.totalPages)) return
    commit('SET_LOADING', true)
    try {
      let { data, headers } = await FamiliesRepository.listFamilies({
        page: getters.currentPage + 1, ...params
      })
      commit('ADD_RECORDS', data)
      commit('SET_RESPONSE_HEADERS', headers)
    } catch (error) {
      console.error(error)
      dispatch('layout/setError', error, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async findRecord({ commit, dispatch }, payload) {
    commit('SET_LOADING', true)
    try {
      let { data, included } = await FamiliesRepository.getFamily(
        payload.id,
        payload.options
      )
      data.included = included
      commit('ADD_RECORD', data)
    } catch (error) {
      console.error(error)
      dispatch('layout/setError', error, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  clearFamilies({ commit }) {
    commit('RESET')
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  getTableOfContents({ commit, state }) {
    let optionsData = {
      object_id: state.community.id,
      object_type: 'Family'
    }
    try {
      ChaptersRepository.listTableOfContents(
        optionsData
      ).then(response => {
        commit('SET_TABLE_OF_CONTENT', response.data.attributes.links)
      })
    } catch (error) {
      console.log(error)
    }
  },
  async getChapters({ commit }, {id, options = {}}) {
    try {
      await ChaptersRepository.getSection(
          {
            object_id: id,
            object_type: 'Family',
            ...options
          }
      )
        .then(response => {
          commit('UPDATE_CHAPTERS', response.data)
        })
    } catch (error) {
      console.error(error)
    }
  },
  async deleteChapter({ dispatch, state }, chapter) {
    try {
      await ChaptersRepository.deleteSection(
        chapter.id,
        {
          object_id: state.community.id,
          object_type: 'Family'
        }
      )
        .then(() => {
          dispatch('getChapters', {id: state.community.id})
          dispatch('getTableOfContents')
        })
    } catch (error) {
      console.error(error)
    }
  },
  createNewChapter({ commit, dispatch, state }, params) {
    commit('SET_LOADING', true)
    ChaptersRepository.createSection(params)
      .then(async (res) => {
        dispatch('setCommunityChangeStatus')
        dispatch('getTableOfContents')
        await dispatch('getChapters', {id: state.community.id})
        dispatch('setCommunityActiveChapter', res.data.id)
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
      .finally(() => {
        commit('SET_LOADING', false)
      })
  },
  updateChapter({ commit, dispatch, state }, chapter) {
    commit('SET_LOADING', true)
    ChaptersRepository.updateChapter(chapter.id, decamelizeKeys(chapter.form))
        .then(()=> {
          dispatch('setCommunityChangeStatus')
          dispatch('getTableOfContents', { id: state.community.id })
        })
        .catch((error) => {
          dispatch('layout/setError', error, {root: true})
        })
        .finally(() => {
          commit('SET_LOADING', false)
        })
  },
  createFamilyChapterAppreciation({ commit, dispatch, state }, { kinshipId, params }) {
    commit('SET_LOADING', true)
    AppreciationsRepository.createAppreciation(params)
        .then(async () => {
          if (kinshipId) {
            await dispatch('members/getChapters', { kinshipId: kinshipId }, { root: true })
          }
          else {
            await dispatch('getChapters', { id: state.community.id })
          }
        })
        .catch((error)=> { dispatch('layout/setError', error, { root: true }) })
        .finally(()=> { commit('SET_LOADING', false) })
  },
  removeFamilyChapterAppreciation({ commit, dispatch, state }, { kinshipId, appreciationId }) {
    commit('SET_LOADING', true)
    AppreciationsRepository.deleteAppreciation(appreciationId)
        .then(async () => {
          if (kinshipId) {
            await dispatch('members/getChapters', { kinshipId: kinshipId }, { root: true })
          }
          else {
            await dispatch('getChapters', { id: state.community.id })
          }
        })
        .catch((error)=> { dispatch('layout/setError', error, { root: true }) })
        .finally(()=> { commit('SET_LOADING', false) })
  },
  setCommunityActiveChapter({ commit }, chapter = '') {
    commit('SET_ACTIVE_CHAPTER', chapter.toString())
  },
  setCommunityChangeStatus({ commit }, isChanged = true) {
    if (!state.community.isChanged) commit('SET_COMMUNITY_CHANGE_STATUS', isChanged)
  },
  updateIsAdmin({ commit }, data) {
    commit('UPDATE_IS_ADMIN', data)
  },
  setCommunitiesViewType({ commit }, type) {
    commit('SET_COMMUNITIES_VIEW_TYPE', type)
  },
  setCommunitiesSearch({ commit }, search) {
    commit('SET_COMMUNITIES_SEARCH', search)
  },
  addNewCommunity(_, payload) {
    // eslint-disable-next-line no-unused-vars
    const newPayload = Object.fromEntries(Object.entries(payload).filter(([_, v]) => v !== ''));
    return FamiliesRepository.createFamily(decamelizeKeys(newPayload))
  },
  async updateCommunity({ commit, dispatch }, payload) {
    try {
      commit('SET_LOADING', true)

      const {data} = await FamiliesRepository.updateFamily(payload.id, decamelizeKeys(payload.form))

      const community = {
        ...camelizeKeys(data)
      }

      commit('SET_COMMUNITY', new Community(community))

      dispatch('setCommunityChangeStatus')

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  updateCommunityAvatar({ dispatch }, signedId) {
   return dispatch('updateCommunity', {
      id: state.community.id,
      form: {
        cover: signedId
      }
    })
  },
  sendInvitations({ state, dispatch }, payload) {
    FamiliesRepository.sendInvitations(state.community.id, payload)
      .then(() => {
        let params = {
          'id': state.community.id,
          'type': 'invited'
        }
        dispatch('members/clearMembers', {}, { root: true })
        dispatch('members/loadNext', params, { root: true })
        dispatch('layout/setSnackbar', 'Invitations sent', { root: true })
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
  },
  getInvitation({ dispatch, commit }, id) {
    return new Promise((resolve, reject) => {
      commit('SET_LOADING', true)
      InvitationsRepository.showInvitation(id)
        .then((res) => {
          commit('SET_INVITATION', camelizeKeys(res.data))
          commit('SET_COMMUNITY', camelizeKeys(res.included.find(
            included => included.type === 'family'
          )))
          resolve(res)
        })
        .catch((error) => {
          dispatch('layout/setError', error, { root: true })
          reject(error)
        })
        .finally(() => {
          commit('SET_LOADING', false)
        })
    })
  },
  async acceptInvitation({ dispatch, commit }, { invitationId, payload }) {
    commit('SET_LOADING', true)
    try {
      await InvitationsRepository.updateInvitation(invitationId, decamelizeKeys(payload))
      dispatch('layout/setSnackbar', 'Invitation accepted', { root: true })
      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  cancelInvitations({ dispatch }, invitationIds) {
    InvitationsRepository.cancelInvitations(invitationIds)
      .then(() => {
        let params = {
          'id': state.community.id,
          'type': 'invited'
        }
        dispatch('members/clearMembers', {}, { root: true })
        dispatch('members/loadNext', params, { root: true })
        dispatch('layout/setSnackbar', 'Invitation canceled', { root: true })
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
  },
  resendInvitations({ dispatch }, invitationIds) {
    InvitationsRepository.resendInvitations(invitationIds)
      .then(() => {
        dispatch('layout/setSnackbar', 'Invitation resent', { root: true })
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
  },
  addOfflineMember({ state, dispatch }, payload) {
    FamiliesRepository.addOfflineMember(state.community.id, payload)
      .then(() => {
        let params = {
          'id': state.community.id,
          'type': 'defaults'
        }
        dispatch('members/clearMembers', {}, { root: true })
        dispatch('members/loadNext', params, { root: true })
        dispatch('layout/setSnackbar', 'Offline member added', { root: true })
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
  },
}

const getters = {
  getIsAdmin: (state) => {
    return state.isAdmin
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
  currentPage: (state) => {
    return parseInt(state.responseHeaders.get('Current-Page') || 0)
  },
  totalPages: (state) => {
    return parseInt(state.responseHeaders.get('Total-Pages') || 0)
  },
  getCommunityById: (state) => {
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
