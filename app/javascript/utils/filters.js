export default {
    truncate(text, lengthParam) {
        if (typeof text === 'string' || text instanceof String) {
            return `${text.substring(0, lengthParam)}${text.length > lengthParam ? '...' : ''}`;
        }
        return '';
    },
};
