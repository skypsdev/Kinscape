import Repository from './repository'

const resource = '/requests'
export default {
  sendMessage (payload) {
    return Repository.post(resource, payload)
  }
}
