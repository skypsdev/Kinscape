const baseURL = '/api/v1'

export default {
  async request (endpoint, method, payload) {
    const url = baseURL + endpoint
    const csrfTag = document.querySelector('meta[name="csrf-token"]')
    let headers = { 'Content-Type': 'application/json' }

    if (csrfTag) headers['X-CSRF-Token'] = csrfTag.getAttribute('content')

    const response = await fetch(url, {
      method: method,
      body: JSON.stringify(payload),
      headers: headers
    })

    if (!response.ok) {
      const errorJson = await response.json()
      let errorMessage = ''

      if (errorJson.message) {
        errorMessage = errorJson.message
      } else {
        errorMessage = errorJson.errors.detail
      }
      throw new Error(errorMessage)
    }

    if (response.status === 204) return {}

    let json = await response.json()
    json.headers = response.headers

    // eslint-disable-next-line no-prototype-builtins
    if (json.hasOwnProperty('unauthenticated_error')) {
      window.location.href = window.location['origin'] + '/sign_in'
    } else {
      return json
    }
  },
  async get (endpoint, payload) {
    const params = new URLSearchParams(payload).toString()
    return this.request(`${endpoint}?${params}`, 'GET')
  },
  async put (endpoint, payload) {
    return this.request(endpoint, 'PUT', payload)
  },
  async patch (endpoint, payload) {
    return this.request(endpoint, 'PATCH', payload)
  },
  async post (endpoint, payload) {
    return this.request(endpoint, 'POST', payload)
  },
  async delete (endpoint, payload) {
    return this.request(endpoint, 'DELETE', payload)
  }
}
