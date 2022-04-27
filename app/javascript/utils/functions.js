export function delay(t, v) {
    return new Promise(function (resolve) {
        setTimeout(resolve.bind(null, v), t)
    })
}

export function on(el, evt, fn, opts = {}) {
    const delegatorFn = e =>
        e.target.matches(opts.target) && fn.call(e.target, e);
    el.addEventListener(
        evt,
        opts.target ? delegatorFn : fn,
        opts.options || false
    );
    if (opts.target) return delegatorFn
}

export function removeEventListenerAll(
    targets,
    type,
    listener,
    options,
    useCapture
) {
    targets.forEach(target =>
        target.removeEventListener(type, listener, options, useCapture)
    )
}
/**
 * Creates an array with n elements removed from the beginning.
 * example: https://www.30secondsofcode.org/js/s/take
 * @param {Array} arr 
 * @param {Number} n 
 * @returns {Array} sliced Array 
 */
export const take = (arr, n = 1) => arr.slice(0, n)

export const smoothScroll = (element, block = "center") =>
    element.scrollIntoView({
        block,
        inline: "nearest",
        behavior: "smooth"
    })

/**
 * Filters out the elements of an array that have one of the specified values.
 * https://www.30secondsofcode.org/js/s/without?from=autocomplete
 * @param {Array} arr array to filter
 * @param  {...any} args filterable arguments
 * @returns 
 */
export const without = (arr, ...args) => arr.filter(v => !args.includes(v))
/**
 * converts to native Array
 * @param {Iterable} list 
 * @returns {Array}
 */
export const toArray = (list) => Array.from(list)
export const pipeFunctions = (...fns) =>
    fns.reduce((f, g) => (...args) => g(f(...args)))

// Picks the key-value pairs corresponding to the given keys from an object
export const pick = (obj, arr) =>
    arr.reduce(
        (acc, curr) => (curr in obj && (acc[curr] = obj[curr]), acc),
        {}
    )

/**
 * Returns all the elements of an array except the last one.
 * @param {*} arr 
 * @returns 
 */
export const initial = arr => arr.slice(0, -1);

/**
 * generate ID
 * @returns {String} random generated ID
 */
export const generateId = () => `f${(~~(Math.random() * 1e8)).toString(16)}`