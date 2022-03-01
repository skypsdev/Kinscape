import Repository from './repository'

const resource = '/user'

export default {
  updateUser (payload = {}) {
    return Repository.put(resource, payload)
  }
}
