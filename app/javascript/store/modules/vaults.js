import Vue from 'vue'
import {  camelizeKeys } from 'humps'

import {
  AttachmentsRepository,
  BoxesRepository
} from '@/repositories'
import { Vault } from '@/models/vaults'
import { splitExtension } from '@/utils/common'

const state = {
  vault: new Vault(),
  loading: false,
  selectedVaultItems: [],
  filters: {
    query: ''
  },
  sorting: {
    sortBy: 'created_at',
    sortDirection: 'DESC'
  },
  responseHeaders: new Headers(),
  // TODO: remove unused state

  error: false,
  all: [],
  included: [],
  vaultMode: 'view',
  currentUserVaults: [],
  currentUserBoxes: [],
  userVaultsLoaded: false,
  forLoad: false,
  boxes: {
    items: [],
    vaults: [],
    activeBox: null,
    headers: new Headers()
  }
  // TODO: end
}

const mutations = {
  SET_LOADING(state, data) {
    state.loading = data
  },
  SET_VAULT(state, payload) {
    state.vault = payload
  },
  SET_ACTION_DIALOG_BOX_ITEMS(state, { items, headers }) {
    Vue.set(state.boxes, 'items', items)
    Vue.set(state.boxes, 'headers', headers)
  },
  SET_ACTION_DIALOG_BOX_VAULTS(state, { vaults, headers }) {
    Vue.set(state.boxes, 'vaults', vaults)
    Vue.set(state.boxes, 'headers', headers)
  },
  SET_ACTION_DIALOG_BOX_INFO(state, payload) {
    Vue.set(state.boxes, 'activeBox', payload)
  },
  UPDATE_VAULT_ITEM(state, { id, itemType, key, value }) {
    const itemIndex = state.vault.items.findIndex(el => el.id == id && el.attributes.itemType == itemType)

    if (itemIndex >= 0) {
      Vue.set(state.vault.items[itemIndex].attributes, key, value)
    }
  },
  CLEAR_VAULT_ITEMS(state) {
    Vue.set(state.vault, 'items', [])
  },
  SELECT_VAULT_ITEMS(state, item) {
    const toItemId = ({ id, attributes }) => `${attributes.itemType}-${id}`

    const selectedIds = state.selectedVaultItems.map(toItemId) || []
    if (selectedIds.includes(toItemId(item))) {
      state.selectedVaultItems = state.selectedVaultItems.filter((el) => el.id !== item.id)
    } else {
      state.selectedVaultItems.push(item)
    }
  },
  UNSELECT_VAULT_ITEMS(state) {
    state.selectedVaultItems = []
  },
  SET_VAULT_FILTERS(state, filters) {
    state.filters = {
      ...state.filters,
      ...filters
    }
  },
  CLEAR_VAULT_FILTERS(state) {
    state.filters = {
      query: ''
    }
  },
  CLEAR_VAULT_SORTING(state) {
    state.sorting = {
      sortBy: 'created_at',
      sortDirection: 'DESC'
    }
  },
  SET_RESPONSE_HEADERS(state, data) {
    state.responseHeaders = data
  },
  SET_VAULT_SORTING(state, sorting) {
    state.sorting = sorting
  },
  SET_FOR_LOAD(state, data) {
    state.forLoad = data
  },
  SET_ERROR(state, data) {
    state.error = data
  },
  LOAD_ALL(state, data) {
    state.all = data
  },
  LOAD_USER_VAULTS(state, data) {
    state.currentUserVaults = data
  },
  LOAD_INCLUDED(state, data) {
    state.included = data
  },
  SET_VAULT_MODE(state, mode) {
    state.vaultMode = mode
  },
  DESELECT_ALL_SELECTED_VAULTS(state) {
    state.selectedVaultFileIds = [];
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
}

const actions = {
  async getVaultItems({ commit, getters, dispatch, state }, { vaultId, params = {} }) {
    const { currentPage, totalPages } = getters
    if (currentPage && (currentPage === totalPages)) return
    commit('SET_LOADING', true)
    try {
      params = {
        page: getters.currentPage + 1,
        perPage: 4,
        ...state.filters,
        ...state.sorting,
        ...params
      }
      const itemsPromise = await AttachmentsRepository.getVaultItems(vaultId, params)
      const vaultPromise = await AttachmentsRepository.getVault(vaultId)

      const res = await Promise.all([itemsPromise, vaultPromise])

      commit('SET_VAULT', new Vault({
        ...state.vault,
        id: vaultId,
        box: null,
        items: [
          ...state.vault.items,
          ...camelizeKeys(res[0].data)
        ],
        attributes: camelizeKeys(res[1].data.attributes)
      }))
      commit('SET_RESPONSE_HEADERS', res[0].headers)
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },

  async getActionDialogBoxItems({ commit, dispatch }, { vaultId, boxId }) {

    commit('SET_LOADING', true)

    try {
      const params = {
        page: 1,
        perPage: 100,
        only_boxes: true,
        boxId
      }

      if (!params.boxId) delete params.boxId

      let { data } = await AttachmentsRepository.getVaultItems(vaultId, params)

      commit('SET_ACTION_DIALOG_BOX_ITEMS', {
        items: camelizeKeys(data),
        headers: null
      })

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async getActionDialogBoxVaults({ commit, dispatch }, { query }) {

    commit('SET_LOADING', true)

    try {
      const params = {
        page: 1,
        perPage: 100,
        query
      }

      if (!query) delete params.query

      let { data } = await AttachmentsRepository.getVaults(params)

      commit('SET_ACTION_DIALOG_BOX_VAULTS', {
        vaults: camelizeKeys(data),
        headers: null
      })

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async getActionDialogBoxInfo({ commit, dispatch }, { vaultId, boxId }) {
    try {
      const { data } = await AttachmentsRepository.getBox(vaultId, boxId)

      commit('SET_ACTION_DIALOG_BOX_INFO', camelizeKeys(data))
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }

  },
  async moveAttachments({ commit, dispatch }, { vaultId, boxId, ids }) {
    try {
      commit('SET_LOADING', true)

      await AttachmentsRepository.moveAttachments(vaultId, boxId, ids)

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async copyAttachments({ commit, dispatch }, { vaultId, boxId, ids, newVaultId }) {
    try {
      commit('SET_LOADING', true)

      await AttachmentsRepository.copyAttachments({ vaultId, boxId, ids, newVaultId })

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  clearVault({ commit }) {
    commit('CLEAR_VAULT_ITEMS')
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  setVaultFilters({ commit }, filters) {
    commit('SET_VAULT_FILTERS', filters)
  },
  clearVaultFilters({ commit }) {
    commit('CLEAR_VAULT_FILTERS')
  },
  setVaultSorting({ commit }, sorting) {
    if (!sorting?.sortBy || !sorting?.sortDirection) {
      sorting = {
        sortBy: 'created_at',
        sortDirection: 'DESC'
      }
    }
    commit('SET_VAULT_SORTING', sorting)
  },
  clearVaultSorting({ commit }) {
    commit('CLEAR_VAULT_SORTING')
  },
  async getBox({ commit, dispatch, state }, { vaultId, boxId }) {
    try {
      commit('SET_LOADING', true);

      const boxInfoPromise = AttachmentsRepository.getBox(vaultId, boxId, { perPage: 40 })
      const vaultInfoPromise = AttachmentsRepository.getVault(vaultId)
      const boxAssetsPromise = AttachmentsRepository.getVaultItems(vaultId,
        {
          boxId,
          perPage: 40,
          ...state.filters,
          ...state.sorting
        })

      const res = await Promise.all([boxInfoPromise, boxAssetsPromise, vaultInfoPromise])
      const [boxInfo, boxAssets, VaultInfo] = res

      const vault = {
        ...state.vault,
        id: vaultId,
        box: camelizeKeys({ ...boxInfo.data.attributes, id: boxId }),
        attributes: camelizeKeys(VaultInfo.data.attributes),
        items: [
          ...state.vault.items,
          ...camelizeKeys(boxAssets.data)
        ]
      }
      commit('SET_VAULT', new Vault(vault))
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async updateBox({ commit, dispatch }, { vaultId, boxId, payload }) {
    try {
      commit('SET_LOADING', true)
      await BoxesRepository.updateBox(vaultId, boxId, payload)
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async uploadVaultFile({ commit, dispatch }, { vaultId, boxId, files }) {
    try {
      commit('SET_LOADING', true)

      const model = files.map(({ signedId, filename }) => ({ title: splitExtension(filename)[0], signed_id: signedId }))
      await AttachmentsRepository.createAttachment(vaultId, { boxId, files: model })

      dispatch('clearVault')

      if (boxId) dispatch('getBox', { vaultId, boxId })
      else dispatch('getVaultItems', { vaultId, params: { page: 1 } })

      return Promise.resolve()
    } catch (error) {
      dispatch('layout/setError', error, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async updateAttachment({ commit, dispatch }, { vaultId, boxId, payload }) {
    try {
      commit('SET_LOADING', true)
      await AttachmentsRepository.updateAttachment(vaultId, boxId, payload)
    } catch (error) {
      dispatch('layout/setError', error.response, { root: true })
      return Promise.reject()
    } finally {
      commit('SET_LOADING', false)
    }
  },
  //
  addVaultBox({ commit, dispatch }, { vaultId, params }) {
    commit('SET_LOADING', true)
    BoxesRepository.createBox(vaultId, params)
      .then(() => {
        dispatch('clearVault')

        const { parentBoxId } = params;

        if (parentBoxId) dispatch('getBox', { vaultId, boxId: parentBoxId })
        else dispatch('getVaultItems', { vaultId, params: { page: 1 } })

        dispatch('layout/closeDialog', null, { root: true })
      })
      .catch((error) => {
        dispatch('layout/setSnackbar', {
          color: 'error',
          messages: [error.message]
        }, { root: true })
      })
      .finally(() => { commit('SET_LOADING', false) })
  },
  clearSelectedAttachments({ commit }) {
    commit('UNSELECT_VAULT_ITEMS')
  },
  toggleVaultItemSelection({ commit }, item) {
    commit('SELECT_VAULT_ITEMS', item)
  },
  deleteSelectedVaultItems({ commit, dispatch, getters }, { boxId, vaultId }) {
    commit('SET_LOADING', true)

    AttachmentsRepository.bulkDeleteAttachments(vaultId, getters.selectedIds)
      .then(() => {
        commit('UNSELECT_VAULT_ITEMS')
        dispatch('clearVault')

        if (boxId) dispatch('getBox', { vaultId, boxId })
        else dispatch('getVaultItems', { vaultId, params: { page: 1 } })

        dispatch('layout/closeDialog', null, { root: true })
      })
      .catch((error) => {
        dispatch('layout/setSnackbar', {
          color: 'error',
          messages: [error.message]
        }, { root: true })
      }).finally(() => {
        commit('SET_LOADING', false)
      })
  },
  // TODO: check and remove unused actions
  /*async loadAll ({ commit }, params = {}) {
    commit('SET_LOADING', true)
    try {
      let response = await AttachmentsRepository.listVaults(params)
      commit('LOAD_ALL', response.data)
      commit('LOAD_INCLUDED', response.included)
      commit('SET_RESPONSE_HEADERS', response.headers)
    } catch (error) {
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },
  async loadNext ({ commit, getters }, params = {}) {
    if (getters.currentPage &&
       (getters.currentPage === getters.totalPages)) return
    commit('SET_LOADING', true)
    try {
      let requestParams = { page: getters.currentPage + 1, ...params }
      let response = await AttachmentsRepository.listVaults(requestParams)
      commit('ADD_RECORDS', response.data)
      commit('SET_RESPONSE_HEADERS', response.headers)
    } catch (error) {
      commit('SET_ERROR', true)
    } finally {
      commit('SET_LOADING', false)
    }
  },*/
  clearVaults({ commit }) {
    commit('LOAD_ALL', [])
    commit('SET_RESPONSE_HEADERS', new Headers())
  },
  setViewVaultMode({ commit }) {
    commit('SET_VAULT_MODE', 'view')
  },
  /*setMoveVaultMode ({ commit }) {
    commit('SET_VAULT_MODE', 'move')
  },
  setDownloadVaultMode ({ commit }) {
    commit('SET_VAULT_MODE', 'download')
  },
  setShareVaultMode ({ commit }) {
    commit('SET_VAULT_MODE', 'share')
  },
  setDeleteVaultMode ({ commit }) {
    commit('SET_VAULT_MODE', 'delete')
  },*/
  setAttachVaultMode({ commit }) {
    commit('SET_VAULT_MODE', 'attach')
  },
  /*setCurrentPage (state, data) {
    state.currentPage = data
  },
  setTotalPages (state, data) {
    state.totalPages = data
  },
  setForLoad ({ commit }, data) {
    commit('SET_FOR_LOAD', data)
  },*/
  filesUploaded({ commit, dispatch, state }, event) {
    commit('SET_FOR_LOAD', false)
    event.filesUploaded.forEach(async (file) => {
      try {
        commit('SET_FOR_LOAD', true)
        const response = await AttachmentsRepository.createAttachment(
          state.vault.id,
          {
            box_id: state.currentBox && state.currentBox.id,
            media_file_attributes: file
          }
        )
        const { attachments, mediaFiles } = state.vault
        attachments.unshift(response.data)
        mediaFiles.unshift(response.included[0])
        const vault = {
          ...state.vault,
          attachments,
          mediaFiles
        }
        commit('SET_VAULT', new Vault(vault))
      } catch (error) {
        dispatch('layout/setError', error, { root: true })
      } finally {
        commit('SET_FOR_LOAD', false)
      }
    })
  }
  // TODO: end
}

const getters = {
  isSelected: (state) => {
    return (id, type) => state.selectedVaultItems.find((a) => a.id === id && a.attributes.itemType === type)
  },
  selectedIds: (state) => {
    const selected = {
      boxesIds: [],
      filesIds: []
    }
    state.selectedVaultItems.forEach((item) => {
      if (item.attributes.itemType === 'box') selected.boxesIds.push(item.id)
      if (item.attributes.itemType === 'file') selected.filesIds.push(item.id)
    })
    return selected
  },
  currentPage: (state) => {
    return parseInt(state.responseHeaders.get('Current-Page') || 0)
  },
  totalPages: (state) => {
    return parseInt(state.responseHeaders.get('Total-Pages') || 0)
  },
  hasMorePages: (state, getters) => {
    const { currentPage, totalPages } = getters
    return currentPage && currentPage < totalPages
  },
  // TODO: check unused getters
  getForLoad: (state) => {
    return state.forLoad
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
  included: (state) => {
    return state.included
  },
  load: (state) => {
    return id => state.all.find(a => a.id === id)
  },
  vaultMode: (state) => {
    return state.vaultMode
  },
  selectedVaultFileIds: (state) => {
    return state.selectedVaultFileIds
  },
  /*currentUserVaults: (state) => {
    return state.currentUserVaults
  },*/
  userVaultsLoaded: (state) => {
    return state.userVaultsLoaded
  },
  currentUserBoxes: (state) => {
    return state.currentUserBoxes
  }
  // TODO: end
}

export default {
  namespaced: true,
  state,
  getters,
  actions,
  mutations
}
