const isString = (value) => typeof value === 'string'
const isBoolean = (value) => typeof value === 'boolean'
const isObject = (object) => typeof object === 'object'
const isEmpty = (object) => !Object.entries(object).length
const isExist = (value) => value !== undefined

export {
  isString,
  isBoolean,
  isObject,
  isEmpty,
  isExist
}
