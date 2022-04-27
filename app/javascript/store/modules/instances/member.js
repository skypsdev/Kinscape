
import { camelizeKeys, decamelizeKeys } from 'humps'

import request from "@/store/reusable/request.js"

import { Member } from '@/models/members'
import { KinshipsRepository } from '@/repositories'

const state = {
    ...request.state,
    member: new Member(),
}
const mutations = {
    ...request.mutations,
    SET_MEMBER(state, payload = {}) {
        state.member = new Member(camelizeKeys(payload))
    }
}
const actions = {
    clearMember({ commit }) {
        commit('SET_MEMBER')
    },
    async getMemberByFamilyId({ commit }, { id, options = { include: 'family' } }) {
        try {
            let res = await KinshipsRepository.getKinshipByFamily(id, options)
            res.data.included = res.included

            commit('SET_MEMBER', res.data)

            return Promise.resolve(res.data)
        } catch (error) {
            commit('SET_ERROR', true)
            console.error(error)

            return Promise.reject(error)
        }
    },
    async getMemberById({ commit }, { id, options = { include: 'family' } }) {
        try {
            let res = await KinshipsRepository.getKinship(
                id,
                options
            )
            res.data.included = res.included

            commit('SET_MEMBER', res.data)

            return Promise.resolve(res.data)

        } catch (error) {
            commit('SET_ERROR', true)
            console.error(error)

            return Promise.reject(error)
        }
    },
    async updateMember({ commit }, { id, form }) {
        try {
            const res = await KinshipsRepository.updateKinship(id, decamelizeKeys(form))

            commit('SET_MEMBER', res.data)

            return Promise.resolve(res.data)

        } catch (error) {
            commit('SET_ERROR', true)
            console.error(error)

            return Promise.reject(error)
        }
    }
}
const getters = {}

export default {
    namespaced: true,
    strict: process.env.NODE_ENV !== 'production',
    state,
    getters,
    actions,
    mutations
}
