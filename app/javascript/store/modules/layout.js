import {Dialog, Snackbar} from '../../models/layoutModels'
import {isString} from '../../utils/common'

export default {
  namespaced: true,
  state: {
    dialog: new Dialog(),
    snackbar: new Snackbar()
  },
  mutations: {
    SET_DIALOG(state, setup) {
      state.dialog = setup
    },
    SET_SNACKBAR(state, setup) {
      state.snackbar = setup
    }
  },
  actions: {
    setDialog({commit}, setup) {
      setup.active = setup.active ? setup.active : true
      commit('SET_DIALOG', new Dialog(setup))
    },
    closeDialog({commit}) {
      commit('SET_DIALOG', new Dialog())
    },
    setSnackbar({commit}, setup) {
      setup = isString(setup) ? {
        active: true,
        messages: isString(setup) ? [setup] : setup.messages
      } : {
        active: true,
        ...setup
      }
      commit('SET_SNACKBAR', new Snackbar(setup))
    },
    setError({commit}, error) {
      if (error) console.error(error)
      commit('SET_SNACKBAR', new Snackbar({
        active: true,
        color: 'error',
        messages: ['Sorry, this action can not be performed.']
      }))
    },
    closeSnackbar({commit}) {
      commit('SET_SNACKBAR', new Snackbar())
    }
  }
};
