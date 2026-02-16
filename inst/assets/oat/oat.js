// oat - Base Web Component Class
// Provides lifecycle management, event handling, and utilities.

class OtBase extends HTMLElement {
  #initialized = false;

  // Called when element is added to DOM.
  connectedCallback() {
    if (this.#initialized) return;

    // Wait for DOM to be ready.
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.#setup(), { once: true });
    } else {
      this.#setup();
    }
  }

  // Private setup to ensure that init() is only called once.
  #setup() {
    if (this.#initialized) return;
    this.#initialized = true;
    this.init();
  }

  // Override in WebComponent subclasses for init logic.
  init() {}

  // Called when element is removed from DOM.
  disconnectedCallback() {
    this.cleanup();
  }

  // Override in subclass for cleanup logic.
  cleanup() {}

  // Central event handler - enables automatic cleanup.
  // Usage: element.addEventListener('click', this)
  handleEvent(event) {
    const handler = this[`on${event.type}`];
    if (handler) handler.call(this, event);
  }

  // Emit a custom event.
  emit(name, detail = null) {
    return this.dispatchEvent(new CustomEvent(name, {
      bubbles: true,
      composed: true,
      cancelable: true,
      detail
    }));
  }

  // Get boolean attribute value.
  getBool(name) {
    return this.hasAttribute(name);
  }

  // Set or remove boolean attribute.
  setBool(name, value) {
    if (value) {
      this.setAttribute(name, '');
    } else {
      this.removeAttribute(name);
    }
  }

  // Query selector within this element.
  $(selector) {
    return this.querySelector(selector);
  }

  // Query selector all within this element.
  $$(selector) {
    return Array.from(this.querySelectorAll(selector));
  }

  // Generate a unique ID string.
  uid() {
    return Math.random().toString(36).slice(2, 10);
  }
}

// Export for use in other files
if (typeof window !== 'undefined') {
  window.OtBase = OtBase;
}

// Polyfill for command/commandfor (Safari)
if (!('commandForElement' in HTMLButtonElement.prototype)) {
  document.addEventListener('click', e => {
    const btn = e.target.closest('[commandfor]');
    if (!btn) return;

    const target = document.getElementById(btn.getAttribute('commandfor'));
    if (!target) return;

    const command = btn.getAttribute('command') || 'toggle';

    if (target instanceof HTMLDialogElement) {
      if (command === 'show-modal') target.showModal();
      else if (command === 'close') target.close();
      else target.open ? target.close() : target.showModal();
    }
  });
}
/**
 * oat - Tabs Component
 * Provides keyboard navigation and ARIA state management.
 *
 * Usage:
 * <ot-tabs>
 *   <div role="tablist">
 *     <button role="tab">Tab 1</button>
 *     <button role="tab">Tab 2</button>
 *   </div>
 *   <div role="tabpanel">Content 1</div>
 *   <div role="tabpanel">Content 2</div>
 * </ot-tabs>
 */

class OtTabs extends OtBase {
  #tabs = [];
  #panels = [];

  init() {
    const tablist = this.$(':scope > [role="tablist"]');
    this.#tabs = tablist ? [...tablist.querySelectorAll('[role="tab"]')] : [];
    this.#panels = this.$$(':scope > [role="tabpanel"]');

    if (this.#tabs.length === 0 || this.#panels.length === 0) {
      console.warn('ot-tabs: Missing tab or tabpanel elements');
      return;
    }

    // Generate IDs and set up ARIA.
    this.#tabs.forEach((tab, i) => {
      const panel = this.#panels[i];
      if (!panel) return;

      const tabId = tab.id || `ot-tab-${this.uid()}`;
      const panelId = panel.id || `ot-panel-${this.uid()}`;

      tab.id = tabId;
      panel.id = panelId;
      tab.setAttribute('aria-controls', panelId);
      panel.setAttribute('aria-labelledby', tabId);

      tab.addEventListener('click', this);
      tab.addEventListener('keydown', this);
    });

    // Find initially active tab or default to first.
    const activeTab = this.#tabs.findIndex(t => t.ariaSelected === 'true');
    this.#activate(activeTab >= 0 ? activeTab : 0);
  }

  onclick(e) {
    const index = this.#tabs.indexOf(e.target.closest('[role="tab"]'));
    if (index >= 0) this.#activate(index);
  }

  onkeydown(e) {
    const { key } = e;
    const idx = this.activeIndex;
    let newIdx = idx;

    switch (key) {
      case 'ArrowLeft':
        e.preventDefault();
        newIdx = idx - 1;
        if (newIdx < 0) newIdx = this.#tabs.length - 1;
        break;
      case 'ArrowRight':
        e.preventDefault();
        newIdx = (idx + 1) % this.#tabs.length;
        break;
      default:
        return;
    }

    this.#activate(newIdx);
    this.#tabs[newIdx].focus();
  }

  #activate(idx) {
    this.#tabs.forEach((tab, i) => {
      const isActive = i === idx;
      tab.ariaSelected = String(isActive);
      tab.tabIndex = isActive ? 0 : -1;
    });

    this.#panels.forEach((panel, i) => {
      panel.hidden = i !== idx;
    });

    this.emit('ot-tab-change', { index: idx, tab: this.#tabs[idx] });
  }

  get activeIndex() {
    return this.#tabs.findIndex(t => t.ariaSelected === 'true');
  }

  set activeIndex(value) {
    if (value >= 0 && value < this.#tabs.length) {
      this.#activate(value);
    }
  }
}

customElements.define('ot-tabs', OtTabs);
/**
 * oat - Dropdown Component
 * Provides positioning, keyboard navigation, and ARIA state management.
 *
 * Usage:
 * <ot-dropdown>
 *   <button popovertarget="menu-id">Options</button>
 *   <menu popover id="menu-id">
 *     <button role="menuitem">Item 1</button>
 *     <button role="menuitem">Item 2</button>
 *   </menu>
 * </ot-dropdown>
 */

class OtDropdown extends OtBase {
  #menu;
  #trigger;
  #position;

  init() {
    this.#menu = this.$('[popover]');
    this.#trigger = this.$('[popovertarget]');

    if (!this.#menu || !this.#trigger) return;

    this.#menu.addEventListener('toggle', this);
    this.#menu.addEventListener('keydown', this);

    this.#position = () => {
      // Position has to be calculated and applied manually because
      // popover positioning is like fixed, relative to the window.
      const rect = this.#trigger.getBoundingClientRect();
      this.#menu.style.top = `${rect.bottom}px`;
      this.#menu.style.left = `${rect.left}px`;
    };
  }

  ontoggle(e) {
    if (e.newState === 'open') {
      this.#position();
      window.addEventListener('scroll', this.#position, true);
      this.$('[role="menuitem"]')?.focus();
      this.#trigger.ariaExpanded = 'true';
    } else {
      window.removeEventListener('scroll', this.#position, true);
      this.#trigger.ariaExpanded = 'false';
      this.#trigger.focus();
    }
  }

  onkeydown(e) {
    if (!e.target.matches('[role="menuitem"]')) return;

    const items = this.$$('[role="menuitem"]');
    const idx = items.indexOf(e.target);

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        items[(idx + 1) % items.length]?.focus();
        break;
      case 'ArrowUp':
        e.preventDefault();
        items[idx - 1 < 0 ? items.length - 1 : idx - 1]?.focus();
        break;
    }
  }

  cleanup() {
    window.removeEventListener('scroll', this.#position, true);
  }
}

customElements.define('ot-dropdown', OtDropdown);
/**
 * oat - Toast Notifications
 *
 * Usage:
 *   ot.toast('Saved!')
 *   ot.toast('Action completed successfully', 'All good')
 *   ot.toast('Operation completed.', 'Success', { variant: 'success' })
 *   ot.toast('Something went wrong.', 'Error', { variant: 'danger', placement: 'bottom-center' })
 *
 *   // Custom markup
 *   ot.toastEl(element)
 *   ot.toastEl(element, { duration: 4000, placement: 'bottom-center' })
 *   ot.toastEl(document.querySelector('#my-template'))
 */

const ot = window.ot || (window.ot = {});

const containers = {};
const DEFAULT_DURATION = 4000;
const DEFAULT_PLACEMENT = 'top-right';

function getContainer(placement) {
  if (!containers[placement]) {
    const el = document.createElement('div');
    el.className = 'toast-container';
    el.setAttribute('popover', 'manual');
    el.setAttribute('data-placement', placement);
    document.body.appendChild(el);
    containers[placement] = el;
  }

  return containers[placement];
}

function show(toast, options = {}) {
  const { placement = DEFAULT_PLACEMENT, duration = DEFAULT_DURATION } = options;
  const container = getContainer(placement);

  toast.classList.add('toast');

  let timeout;

  // Pause on hover.
  toast.onmouseenter = () => clearTimeout(timeout);
  toast.onmouseleave = () => {
    if (duration > 0) {
      timeout = setTimeout(() => removeToast(toast, container), duration);
    }
  };

  // Show with animation.
  toast.setAttribute('data-entering', '');
  container.appendChild(toast);
  container.showPopover();

  // Double RAF to compute styles before transition starts.
  requestAnimationFrame(() => {
    requestAnimationFrame(() => {
      toast.removeAttribute('data-entering');
    });
  });

  if (duration > 0) {
    timeout = setTimeout(() => removeToast(toast, container), duration);
  }

  return toast;
}

// Simple text toast.
ot.toast = function (message, title, options = {}) {
  const { variant = 'info', ...rest } = options;

  const toast = document.createElement('output');
  toast.setAttribute('data-variant', variant);

  if (title) {
    const titleEl = document.createElement('h6');
    titleEl.className = 'toast-title';
    titleEl.style.color = `var(--${variant})`;
    titleEl.textContent = title;
    toast.appendChild(titleEl);
  }

  if (message) {
    const msgEl = document.createElement('div');
    msgEl.className = 'toast-message';
    msgEl.textContent = message;
    toast.appendChild(msgEl);
  }

  return show(toast, rest);
};

// Element-based toast.
ot.toastEl = function (el, options = {}) {
  let toast;

  if (el instanceof HTMLTemplateElement) {
    toast = el.content.firstElementChild.cloneNode(true);
  } else if (typeof el === 'string') {
    toast = document.querySelector(el).cloneNode(true);
  } else {
    toast = el.cloneNode(true);
  }

  toast.removeAttribute('id');

  return show(toast, options);
};

function removeToast(toast, container) {
  if (toast.hasAttribute('data-exiting')) {
    return;
  }
  toast.setAttribute('data-exiting', '');

  const cleanup = () => {
    toast.remove();
    if (!container.children.length) {
      container.hidePopover();
    }
  };

  toast.addEventListener('transitionend', cleanup, { once: true });
  setTimeout(cleanup, 200);
}

// Clear all toasts.
ot.toast.clear = function (placement) {
  if (placement && containers[placement]) {
    containers[placement].innerHTML = '';
    containers[placement].hidePopover();
  } else {
    Object.values(containers).forEach(c => {
      c.innerHTML = '';
      c.hidePopover();
    });
  }
};
/**
 * oat - Tooltip Enhancement
 * Converts title attributes to data-tooltip for custom styling.
 * Progressive enhancement: native title works without JS.
 */

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('[title]').forEach(el => {
    const text = el.getAttribute('title');
    if (text) {
      el.setAttribute('data-tooltip', text);
      if (!el.hasAttribute('aria-label')) {
        el.setAttribute('aria-label', text);
      }
      el.removeAttribute('title');
    }
  });
});
/**
 * Sidebar toggle handler
 * Toggles data-sidebar-open on layout when toggle button is clicked
 */
document.addEventListener('click', (e) => {
  const toggle = e.target.closest('[data-sidebar-toggle]');
  if (toggle) {
    const layout = toggle.closest('[data-sidebar-layout]');
    layout?.toggleAttribute('data-sidebar-open');
  }
});
