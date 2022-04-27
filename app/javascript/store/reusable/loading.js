export const state = {
    loading: false
}

export const mutations = {
    SET_LOADING(state, data) {
        state.loading = data
    }
}

export default { state, mutations }