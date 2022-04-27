import Vue from 'vue'
import { camelizeKeys } from 'humps'
import { FollowRepository, KinshipsRepository } from '@/repositories/index.js'


const options = () => ({
    data: [],
    responseHeaders: new Headers()
})

const state = {
    loading: false,
    followings: {
        ...options()
    },
    followers: {
        ...options()
    },
}

const mutations = {
    SET_LOADING(state, payload = false) {
        state.loading = payload
    },
    SET_RESPONSE_HEADERS(state, { instance, headers = new Headers() }) {
        Vue.set(state[instance], 'responseHeaders', headers)
    },
    SET_FOLLOWINGS(state, data = []) {
        Vue.set(state['followings'], 'data', data)
    },
    SET_FOLLOWERS(state, data = []) {
        Vue.set(state['followers'], 'data', data)
    },
    DELETE_FOLLOW(state, { id, instance }) {
        const deletedIndex = state[instance].data.findIndex(el => el.id == id)

        if (deletedIndex >= 0) {
            Vue.delete(state[instance]['data'], deletedIndex)
        }
    }
}

const getters = {
    totalFollow({ followings, followers }) {
        return followings.data.length + followers.data.length
    }
}

const actions = {
    async getFollowers({ dispatch, commit }, params) {
        try {
            const { data, headers } = await FollowRepository.getFollowers(params)

            commit('SET_FOLLOWERS', camelizeKeys(data))
            commit('SET_RESPONSE_HEADERS', { instance: 'followers', headers })

        } catch (error) {
            console.error(error)
            dispatch('layout/setError', error.response, { root: true })
        }
    },
    async getFollowings({ dispatch, commit }, params) {
        try {
            const { data, headers } = await FollowRepository.getFollowings(params)

            commit('SET_FOLLOWINGS', camelizeKeys(data))
            commit('SET_RESPONSE_HEADERS', { instance: 'followings', headers })

        } catch (error) {
            console.error(error)
            dispatch('layout/setError', error.response, { root: true })
        }
    },
    // payload consist of { id[kinshipId], instance['followings', 'followers'] }
    async unFollow({ commit, dispatch }, payload) {
        commit('SET_LOADING', true)
        try {
            if (payload.instance == 'followings') {
                await FollowRepository.deleteFollowing(payload.id)
            } else {
                await KinshipsRepository.kinshipDelete(payload.id)
            }
            commit('DELETE_FOLLOW', payload)

            return Promise.resolve()
        } catch (error) {
            console.error(error)
            dispatch('layout/setError', error.response, { root: true })
        } finally {
            commit('SET_LOADING', false)
        }
    }
}

export default {
    namespaced: true,
    state,
    getters,
    actions,
    mutations
}
