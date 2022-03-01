import Vue from 'vue'
import Vuex from 'vuex'
import core from './modules/core'
import vaults from './modules/vaults'
import sections from './modules/sections'
import stories from './modules/stories'
import comments from './modules/comments'
import families from './modules/families'
import kinships from './modules/kinships'
import members from './modules/members'
import layout from './modules/layout'
import conversations from './modules/conversations'

Vue.use(Vuex)

const csrfTag = document.querySelector('meta[name="csrf-token"]')
let headers = { 'Content-Type': 'application/vnd.api+json' }
if (csrfTag) headers['X-CSRF-Token'] = csrfTag.getAttribute('content')

export const store = new Vuex.Store({
  modules: {
    core,
    vaults,
    sections,
    stories,
    comments,
    families,
    kinships,
    members,
    layout,
    conversations
  },
  state: {
    showUploadInProgressBeforeUnload: true,
    sectionUpdateQueued: false,
    flashMessage: {},
    savingStatus: 'initial',
    familyData: []
  },
  mutations: {
    switchUploadInProgressBeforeUnloadNotification (state, payload) {
      state.showUploadInProgressBeforeUnload = payload
    },
    switchSectionUpdateQueued (state, payload) {
      state.sectionUpdateQueued = payload
    },
    setFlashMessage (state, payload) {
      state.flashMessage = payload
    },
    setSavingStatus (state, payload) {
      state.savingStatus = payload
    }
  },
  actions: {
    uploadInProgressBeforeUnloadOn ({ commit }) {
      commit('switchUploadInProgressBeforeUnloadNotification', true)
    },
    uploadInProgressBeforeUnloadOff ({ commit }) {
      commit('switchUploadInProgressBeforeUnloadNotification', false)
    },
    queueSectionUpdate ({ commit }) {
      commit('switchSectionUpdateQueued', true)
    },
    unqueueSectionUpdate ({ commit }) {
      commit('switchSectionUpdateQueued', false)
    },
    successFlashMessage ({ commit }, message) {
      commit('setFlashMessage', { type: 'success', message })
    },
    failureFlashMessage ({ commit }, message) {
      commit('setFlashMessage', { type: 'failure', message })
    },
    startedSavingStatus ({ commit }) {
      commit('setSavingStatus', 'started')
    },
    finishedSavingStatus ({ commit }) {
      commit('setSavingStatus', 'finished')
    },
    failedSavingStatus ({ commit }) {
      commit('setSavingStatus', 'failed')
    }
  },
  getters: {
    isLoading (state) {
      return Object.keys(state).some(s => state[s] && state[s].loading)
    },
    showUploadInProgressBeforeUnload (state) {
      return state.showUploadInProgressBeforeUnload
    },
    sectionUpdateQueued (state) {
      return state.sectionUpdateQueued
    },
    flashMessage (state) {
      return state.flashMessage
    },
    savingStatus (state) {
      return state.savingStatus
    }
  }
})
