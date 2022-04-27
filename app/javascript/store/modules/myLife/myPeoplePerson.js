import memberModule from '@/store/modules/instances/member.js'
import chaptersModule from '@/store/modules/instances/chapters'

import loading from "@/store/reusable/loading.js"

export default {
    namespaced: true,
    strict: process.env.NODE_ENV !== 'production',
    modules: {
        member: memberModule,
        chapters: chaptersModule
    },
    state: { ...loading.state },
    getters: {},
    mutations: { ...loading.mutations },
    actions: {
        async getChapters({ commit, dispatch }, id) {
            commit('SET_LOADING', true)
            try {
                await dispatch('chapters/getChapters', { id })

            } finally {
                commit('SET_LOADING', false)
            }
        },
        async loadData({ commit, dispatch }, id) {
            commit('SET_LOADING', true)
            try {
                await Promise.all([
                    dispatch('member/getMemberById', { id }),
                    dispatch('chapters/getChapters', { id })
                ])

            } finally {
                commit('SET_LOADING', false)
            }
        },
    }
}