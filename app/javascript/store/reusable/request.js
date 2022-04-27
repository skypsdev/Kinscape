
export const state = {
    error: false,
    responseHeaders: new Headers()
}

export const mutations = {
    SET_RESPONSE_HEADERS(state, data) {
        state.responseHeaders = data
    },
    SET_ERROR(state, data) {
        state.error = data
    }
}

export const getters = {
    currentPage: (state) => {
        return parseInt(state.responseHeaders.get('Current-Page') || 0)
    },
    totalPages: (state) => {
        return parseInt(state.responseHeaders.get('Total-Pages') || 0)
    },
}

export default {
    state,
    mutations,
    getters
}