

import { camelizeKeys } from 'humps'

import request from "@/store/reusable/request.js"

import { Member } from '@/models/members'
import { KinshipsRepository } from '@/repositories'

export default {
    namespaced: true,
    strict: process.env.NODE_ENV !== 'production',
    state: {
        ...request.state,
        members: [],
    },
    getters: {
        ...request.getters,
    },
    mutations: {
        ...request.mutations,
        ADD_MEMBERS(state, payload = []) {
            const toMembers = arr => arr.map(rec => new Member(camelizeKeys(rec)))
            state.members.push(...toMembers(payload))
        },
    },
    actions: {
        async loadMembers({ commit }, id, params = {}) {
            try {
                const response = await KinshipsRepository.listKinships(
                    id,
                    params
                )

                commit('ADD_MEMBERS', response.data)
                commit('SET_RESPONSE_HEADERS', response.headers)

                Promise.resolve(response.data)
            } catch (error) {
                commit('SET_ERROR', true)
                console.error(error)

                return Promise.reject(error)
            }
        },
        async loadNextPage({ commit, getters, dispatch }, id, params = {}) {
            if (getters.currentPage && getters.currentPage === getters.totalPages) {
                return Promise.resolve()
            }

            try {
                const requestParams = { page: getters.currentPage + 1, ...params }
                const res = await dispatch.loadMembers(
                    id,
                    requestParams
                )

                Promise.resolve(res)
            } catch (error) {
                commit('SET_ERROR', true)
                console.error(error)

                return Promise.reject(error)
            }
        },
    }
}