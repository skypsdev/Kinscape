import { initial } from "@/utils/functions.js"

const isString = (value) => typeof value === 'string'
const isBoolean = (value) => typeof value === 'boolean'
const isObject = (object) => typeof object === 'object'
const isEmpty = (object) => !Object.entries(object).length
const isExist = (value) => value !== undefined
const splitExtension = fileName => {
  const nameArr = fileName.split('.')

  return [initial(nameArr).join('.'), nameArr.pop()]
}

export {
  splitExtension,
  isString,
  isBoolean,
  isObject,
  isEmpty,
  isExist
}
