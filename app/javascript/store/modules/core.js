import {User} from '../../models/users'
import {camelizeKeys} from 'humps'
import { Ability } from '@casl/ability'
import router from '@/packs/router'
import { subject as an } from '@casl/ability'
import usersRepository from '@/repositories/users-repository'

export default {
  namespaced: true,
  state: {
    user: new User(),
    rules: [],
    isLoading: true,
    showTooltips: true
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
    async initApp ({ commit, getters }, user) {
      try {
        let {data} = camelizeKeys(user)
        commit('SET_USER', new User(data))
        const rules = data.attributes?.abilities || []
        commit('SET_RULES', rules)
        getters.ability.update(rules)
        commit('APP_IS_LOADED')
        return Promise.resolve()
      } catch (err) {
        console.error(err)
        return Promise.reject()
      }
      
    },
    closeTooltip ({ state }, tooltipName) {
      state.user.onboarding.tooltip = {
        ...state.user.onboarding.tooltip,
        [tooltipName]: true
      }

      const { onboarding } = state.user
      usersRepository.updateUser({
        onboarding: {
          ...onboarding,
          tooltip: {
            ...onboarding.tooltip,
            [tooltipName]: true
          }
        }
      })
    },
    showTooltips ({ state }, flag = true) {
      state.showTooltips = flag
    }
  },
  getters: {
    ability() {
      return new Ability()
    },
    communityTooltip (state, getters, rootState) {
      const { params, name } = router?.app?.$route || {}
      const { tooltip } = state.user.onboarding

      if (!params.id) { return '' }

      const userId = rootState.myPeoplePerson.member.member?.userId
      const communityMemberCount = rootState.families.simpleList.families
        .find(({ id }) => id === params.id)?.relationships.kinships?.data.length

      if (
        getters.ability.can(
          'manage',
          an('Family', { id: params.id })
        ) && !tooltip.addChapter
      ) {
        return 'addChapter'
      } else if (
        userId &&
        state.user.id?.toString() === userId?.toString() &&
        !tooltip.startConversation
      ) {
        return 'startConversation'
      } if (name === 'showFamily' && communityMemberCount === 1 && !tooltip.communityMembers) {
        return 'communityMembers'
      }

      return ''
    },
    storyTooltip (state) {
      const { tooltip } = state.user.onboarding
      const { name } = router?.app?.$route || {}
      
      if (name === 'stories' && !tooltip.storyFilters) {
        return 'storyFilters'
      }
      if (name === 'showStory' && !tooltip.commentLike) {
        return 'commentLike'
      }

      return ''
    },
    activeTooltip (state, getters) {
      const { fullPath, name } = router?.app?.$route || {}

      if (!fullPath) { return '' }
      if (!state.user?.onboarding?.tooltip) { return '' }
      if (!state.showTooltips) { return '' }

      const { tooltip } = state.user.onboarding

      if (!tooltip.burger) {
        return 'burger'
      }

      if (fullPath === '/communities' && !tooltip.newCommunity) {
        return 'newCommunity'
      } else if (!tooltip.newStory) {
        return 'newStory'
      }

      if (fullPath.startsWith('/communities')) {
        return getters.communityTooltip
      } else if (fullPath.startsWith('/stories')) {
        return getters.storyTooltip
      } else if (name === 'myProfile') {
        if (!tooltip.profiles) {
          return 'profiles'
        } else if (!tooltip.lifeStories) {
          return 'lifeStories'
        }
      }

      return ''
    }
  }
};
