import Vue from 'vue'
import {camelizeKeys, decamelizeKeys} from 'humps'

import {SectionsRepository, StoriesRepository, PublicationsRepository, AppreciationsRepository} from '../../repositories'
import {Story} from '../../models/stories'

const state = {
  loading: false,
  error: false,
  allStories: [],
  responseHeaders: new Headers(),
  familyType: '',
  chapterList: '',
  storyFilter: 'draft',
  viewType: 'grid',
  filters: {
    familyId: '',
    publicationVisibility: '',
    categories: [],
    authorId: '',
    query: ''
  },
  sorting: {
    sortBy: null,
    sortDirection: null
  },
  story: new Story(),
  simpleList: [],
  activeChapter: '',
  allCategories: []
}

const mutations = {
  SET_CATEGORIES (state, categories) {
    state.allCategories = categories
  },
  SET_LOADING (state, status) {
    state.loading = status
  },
  SET_STORY_LOADING (state, isLoading) {
    Vue.set(state.story, 'isLoading', isLoading)
  },
  SET_STORY (state, payload) {
    state.story = payload
  },
  SET_STORIES (state, data) {
    state.allStories = [
      ...state.allStories,
      ...data
    ]
  },
  CLEAR_STORIES (state) {
    state.allStories = []
  },
  SET_STORY_CHANGE_STATUS(state, isChanged = true) {
    state.story.isChanged = isChanged
  },
  SET_STORY_CHAPTER_ADDED(state, chapter) {
    state.story.chapterAdded = chapter
  },
  SET_TABLE_OF_CONTENT (state, links) {
    state.story.content.links = links
  },
  SET_ACTIVE_CHAPTER (state, chapter) {
    state.activeChapter = chapter
  },
  UPDATE_CHAPTER_LIST (state, data) {
    state.chapterList = data
  },
  FOR_FAMILY_TYPE (state, data) {
    state.familyType = data
  },
  SET_RESPONSE_HEADERS (state, data) {
    state.responseHeaders = data
  },
  SET_STORY_FILTERS (state, filters) {
    state.filters = {
      ...state.filters,
      ...filters
    }
  },
  CLEAR_STORY_FILTERS (state) {
    state.filters = {
      familyId: '',
      publicationVisibility: '',
      categories: [],
      authorId: '',
      query: ''
    }
  },
  SET_STORY_SORTING (state, sorting) {
    state.sorting = sorting
  },
  SET_STORIES_VIEW_TYPE(state, type) {
    state.viewType = type
  },
  SET_STORIES_SIMPLE_LIST(state, list) {
    state.simpleList = list
  },
  SET_STORY_CATEGORIES(state, allCategories) {
    state.allCategories = allCategories
  }
}

const actions = {
  async getPublications({ commit, getters, dispatch, state }, params = {}) {
    const {currentPage, totalPages } = getters
    if (currentPage && (currentPage === totalPages)) return
    commit('SET_LOADING', true)
    try {

      const requestParams = {
        page: getters.currentPage + 1,
        include: 'story',
        ...state.filters,
        ...state.sorting,
        ...params
      }
      const res = await PublicationsRepository.listPublications(requestParams)
      const stories = res.data.map((publication) => {
        const storyId = publication.relationships?.story?.data?.id || null
        const story = res.included.find((include) => (include.type === 'story' && include.id === storyId)) || {}
        const familyId = publication.relationships?.family?.data?.id || null
        const family = res.included.find((include) => (include.type === 'family' && include.id === familyId)) || {}

        return {
          ...story,
          community: family,
          publication
        }
      })
      commit('SET_STORIES', camelizeKeys(stories))
      commit('SET_RESPONSE_HEADERS', res.headers)
      dispatch('setAllStoryCategories', res.headers)
    } catch (error) {
      dispatch('layout/setError', error, {root: true})
    } finally {
      commit('SET_LOADING', false)
    }
  },
  getPublication({ commit, dispatch }, payload) {
    commit('SET_STORY_LOADING', true)
    PublicationsRepository.getPublication(payload.id, payload.options)
      .then((res)=> {
        const {data, included} = camelizeKeys(res)
        const story = getNewStory(included, data)

        commit('SET_STORY', story)
        commit('comments/SET_COMMENTS', included.filter((include) => (include.type === 'comment')), { root: true })

        dispatch('sections/loadNext', {id: story.publication.id, params: payload.options}, {root: true } )
      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(() => {
        commit('SET_STORY_LOADING', false)
      })
  },
  setAllStoryCategories({commit}, headers) {
    let allCategories = JSON.parse(headers.get('All-Stories-Categories')) || []
    commit('SET_STORY_CATEGORIES', allCategories)
  },
  updateStory({state, commit, dispatch }, payload) {
    commit('SET_STORY_LOADING', true)
    StoriesRepository.updateStory(payload.id, decamelizeKeys(payload.form))
      .then((res) => {

        const { data } = camelizeKeys(res)
        const story = getNewStory([data], state.story.publication)

        commit('SET_STORY', {...story, isLoading:true})

        dispatch('setStoryChangeStatus')
      })
      .catch((error) => {
        dispatch('layout/setError', error, { root: true })
      })
      .finally(() => {
        setTimeout(() => {
          commit('SET_STORY_LOADING', false)
        }, 500)
      })
  },
  updateStoryAvatar({ state, dispatch }, payload) {
    return dispatch('updateStory', {
      id: state.story.publication.id,
      form: {
        story: {
          cover: payload
        }
      }
    })
  },
  setStoryChangeStatus({commit}, isChanged= true) {
    if (!state.story.isChanged) commit('SET_STORY_CHANGE_STATUS', isChanged)
  },
  setStoryChangeChapterStatus({commit}, chapter = '') {
    if (!state.story.chapterAdded) commit('SET_STORY_CHAPTER_ADDED', chapter.toString())
  },
  createStoryAppreciation({commit, dispatch, state}, params) {
    commit('SET_STORY_LOADING', true)
    AppreciationsRepository.createAppreciation(params)
      .then((res)=> {
        const story = { ...state.story }
        story.publication.attributes.appreciationId = res.data.id
        story.publication.attributes.appreciationsCount++
        commit('SET_STORY', story)
      })
      .catch((error)=> { dispatch('layout/setError', error, {root: true}) })
      .finally(()=> { commit('SET_STORY_LOADING', false) })
  },
  removeStoryAppreciation({commit, dispatch, state}, { appreciationId }) {
    commit('SET_STORY_LOADING', true)
    AppreciationsRepository.deleteAppreciation(appreciationId)
      .then(()=> {
        const story = { ...state.story }
        story.publication.attributes.appreciationId = ''
        story.publication.attributes.appreciationsCount--
        commit('SET_STORY', story)
      })
      .catch((error)=> { dispatch('layout/setError', error, {root: true}) })
      .finally(()=> { commit('SET_STORY_LOADING', false) })
  },
  getTableOfContent({commit}, id) {
    StoriesRepository.listTableOfContents(id)
      .then(response => {
        commit('SET_TABLE_OF_CONTENT', response.data.attributes.links)
      })
  },
  updateChapter({commit, dispatch}, chapter) {
    commit('SET_STORY_LOADING', true)
    SectionsRepository.updateSection(state.story.publication.id, chapter.id, decamelizeKeys(chapter.form))
      .then(()=> {
        dispatch('setStoryChangeStatus')
        dispatch('setStoryActiveChapter', chapter.id)
        dispatch('getTableOfContent', state.story.publication.id)
      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(() => {
        commit('SET_STORY_LOADING', false)
      })
  },
  deleteChapter({commit, dispatch}, chapter) {
    commit('SET_STORY_LOADING', true)
    SectionsRepository.deleteSection(state.story.publication.id, chapter.id)
      .then(()=> {
        dispatch('setStoryChangeStatus')
        dispatch('sections/deleteSection', chapter, {root: true})
        dispatch('getTableOfContent', state.story.publication.id)
      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(()=> {
        commit('SET_STORY_LOADING', false)
      })
  },
  createNewChapter({commit, dispatch}, params) {
    commit('SET_STORY_LOADING', true)
    SectionsRepository.createSection(state.story.publication.id, params)
      .then((res)=> {
        dispatch('setStoryChangeChapterStatus', res.data.id)
        dispatch('getTableOfContent', state.story.publication.id)
        if (res.data.attributes.position !== state.story.content.links.length) {
          dispatch('sections/clearSections', null, {root: true})
        }
        dispatch('setStoryActiveChapter', res.data.id)

      })
      .catch((error) => {
        dispatch('layout/setError', error, {root: true})
      })
      .finally(()=> {
        commit('SET_STORY_LOADING', false)
      })
  },
  createChapterAppreciation({ commit, dispatch }, params) {
    commit('SET_STORY_LOADING', true)
    AppreciationsRepository.createAppreciation(params)
        .then((res)=> {
          dispatch('sections/loadAll', state.story.publication.id, {root: true})
          return res
        })
        .catch((error)=> { dispatch('layout/setError', error, {root: true}) })
        .finally(()=> { commit('SET_STORY_LOADING', false) })
  },
  removeChapterAppreciation({ commit, dispatch }, { appreciationId }) {
    commit('SET_STORY_LOADING', true)
    AppreciationsRepository.deleteAppreciation(appreciationId)
        .then((res)=> {
          dispatch('sections/loadAll', state.story.publication.id, {root: true})
          return res
        })
        .catch((error)=> { dispatch('layout/setError', error, {root: true}) })
        .finally(()=> { commit('SET_STORY_LOADING', false) })
  },
  setStoryActiveChapter ({commit}, chapter = '') {
    commit('SET_ACTIVE_CHAPTER', chapter.toString())
  },
  async createNewStory ({ dispatch, state }) {
    try {
      return await StoriesRepository.createStory(state.story)
    } catch (error) {
      dispatch('layout/setError', error, {root: true})
    }
  },
  clearStories ({ commit }) {
    commit('CLEAR_STORIES')
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  forFamilyType ({ commit }, data) {
    commit('FOR_FAMILY_TYPE', data)
  },
  updateChapterList ({ commit }, data) {
    commit('UPDATE_CHAPTER_LIST', data)
  },
  setStoryFilters({commit}, filters) {
    if (filters) {
      delete filters.sortBy
      delete filters.sortDirection
    }
    commit('SET_STORY_FILTERS', filters)
  },
  clearStoryFilters({commit}) {
    commit('CLEAR_STORY_FILTERS')
  },
  setStorySorting({commit}, sorting) {
    if (!sorting?.sortBy || !sorting?.sortDirection) {
      sorting = {
        sortBy: null,
        sortDirection: null
      }
    }
    commit('SET_STORY_SORTING', sorting)
  },
  setStoriesViewType({commit}, type) {
    commit('SET_STORIES_VIEW_TYPE', type)
  },
  getStoriesSimpleList({ commit }, params ) {
    const {authorId, familyId, ...rest} = params
    let filters = {}
    filters = { familyId, authorId, ...rest }
    PublicationsRepository.listPublications({
      no_pagination: true,
      ...decamelizeKeys(filters)
    }).then((res) => {
      const stories = res.data.map((publication) => {
        const storyId = publication.relationships?.story?.data?.id || null
        if (storyId) {
          return {
            ...res.included.find((include) => (include.type === 'story' && include.id === storyId)),
            publication
          }
        }
      })
      commit('SET_STORIES_SIMPLE_LIST', camelizeKeys(stories))
    }).catch(() => {
      commit('SET_STORIES_SIMPLE_LIST', [])
    })
  },
  clearStoriesSimpleList({commit}) {
    commit('SET_STORIES_SIMPLE_LIST', [])
  },
  async createPublication({ dispatch }, payload) {
    try {
      const params = { publication: decamelizeKeys(payload.publication) }

      return await PublicationsRepository.createPublication(params)
    } catch (error) {
      dispatch('layout/setError', error)
    }
  },
  getCategories({ commit }) {
    PublicationsRepository.getCategories().then((res) => {
      commit('SET_CATEGORIES', camelizeKeys(res.data))
    })
  }
}

const getters = {
  getChapterList: (state) => {
    return state.chapterList
  },
  getFamilyType: (state) => {
    return state.familyType
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
  },
  currentPage: (state) => {
    return parseInt(state.responseHeaders.get('Current-Page') || 0)
  },
  totalPages: (state) => {
    return parseInt(state.responseHeaders.get('Total-Pages') || 0)
  },
  allTags: (state) => {
    const allTags = state.responseHeaders.get('All-Stories-Tags')
    if (!allTags) return
    return allTags.split(', ')
  },
  hasMorePages: (state, getters) => {
    const {currentPage, totalPages} = getters
    return currentPage && currentPage < totalPages
  }
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}

function getNewStory(included, publication) {
  return  new Story({
    ...included.find(i => i.type === 'story') || {},
    publication,
    family: included.find(i => i.type === 'family' && i.id === publication.attributes.familyId) || {},
    publications: included.filter(i => i.type === 'publication') || {},
    families: included.filter(i => i.type === 'family') || {}
  })
}
