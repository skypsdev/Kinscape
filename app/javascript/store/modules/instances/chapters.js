import { pick } from "lodash"

import chaptersRepository from "@/repositories/chapters-repository"
import request from "@/store/reusable/request.js"

export default {
    namespaced: true,
    strict: process.env.NODE_ENV !== 'production',
    modules: {},
    state: {
        ...request.state,
        chapters: [],
        activeChapter: ''
    },
    getters: {
        links: (state) => {
            return state.chapters.map(el => ({
                id: el.id,
                ...pick(el.attributes, ['title', 'position'])
            }))
        }
    },
    mutations: {
        ...request.mutations,
        SET_CHAPTERS(state, payload = []) {
            state.chapters = payload
        },
        SET_ACTIVE_CHAPTER(state, payload) {
            state.activeChapter = payload
        },
    },
    actions: {
        async getChapters({ commit }, { id, type = "Kinship" }) {
            try {
                const res = await chaptersRepository.getSection({
                    object_id: id,
                    object_type: type
                })

                commit('SET_CHAPTERS', res.data)
                return Promise.resolve(res.data)
            } catch (error) {
                commit('SET_ERROR', true)
                console.error(error)

                return Promise.reject(error)
            }
        },
        setActiveChapter({ commit }, id = '') {
            commit('SET_ACTIVE_CHAPTER', id.toString())
        },
        clearChapters({ commit }) {
            commit('SET_CHAPTERS')
        },
    }
}