class Dialog {
  constructor(setup = {}) {
    this.active = setup.active || false
    this.scrollable = setup.scrollable ?? true;
    this.size = setup.size || 'default'
    this.component = setup.component || null
    this.title = setup.title || null
    this.isToolbarHidden = setup.isToolbarHidden || false
    this.data = setup.data || {}
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
