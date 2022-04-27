import {decamelizeKeys} from 'humps'

import Repository from './repository'
const followers = '/followers'
const followings = '/followings'

export default {
  getFollowers ( params = {}) {
    return Repository.get(`${followers}`, decamelizeKeys(params))
  },
  getFollowings( params = {}) {
    return Repository.get(`${followings}`, decamelizeKeys(params))
  },
   deleteFollowing(id) {
    return Repository.delete(`${followings}/${id}`)
  }
}
