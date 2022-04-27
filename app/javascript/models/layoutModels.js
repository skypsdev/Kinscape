class Dialog {
  constructor(setup = {}) {
    this.active = setup.active || false
    this.scrollable = setup.scrollable ?? true;
    this.size = setup.size || 'default'
    this.customSize = setup.customSize || ''
    this.customClass = setup.customClass || ''
    this.component = setup.component || null
    this.title = setup.title || null
    this.isToolbarHidden = setup.isToolbarHidden || false
    this.data = setup.data || {}
    this.persistent = setup.persistent || false
    this.hideCloseBtn = setup.hideCloseBtn || false
  }
}

class Snackbar {
  constructor(setup = {}) {
    this.active = setup.active || false;
    this.messages = setup.messages || [];
    this.color = setup.color || "success";
  }
}

export { Dialog, Snackbar };
