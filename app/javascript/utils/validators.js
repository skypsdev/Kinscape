const externalRules = {
  required: (value) => {
    if (value && value instanceof Array && value.length === 0) {
      return 'This field is required';
    }
    return typeof value === 'number' ? true : (!!value || 'This field is required');
  }
};

export default externalRules;
