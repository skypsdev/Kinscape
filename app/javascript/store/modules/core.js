import {User} from '../../models/users'
import {camelizeKeys} from 'humps'
import { Ability } from '@casl/ability'

export default {
  namespaced: true,
  state: {
    user: new User(),
    rules: [],
    isLoading: true
  },
  mutations: {
    APP_IS_LOADED(state) {
      state.isLoading = false
    },
    SET_USER (state, user) {
      state.user = user
    },
    SET_RULES (state, rules) {
      state.rules = rules
    }
  },
  actions: {
    initApp ({ commit, dispatch, getters }, user) {
      let {data} = camelizeKeys(user)
      commit('SET_USER', new User(data))
      const rules = data.attributes?.abilities || []
      commit('SET_RULES', rules)
      getters.ability.update(rules)
      commit('APP_IS_LOADED')
      dispatch('families/loadQuickList', null, { root: true })
    }
  },
  getters: {
    ability() {
      return new Ability()
    }
  }
};
