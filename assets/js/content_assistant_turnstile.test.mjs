import assert from "node:assert/strict";
import test from "node:test";

import {
  TURNSTILE_ERROR_MESSAGE,
  createContentAssistantTurnstileHook,
} from "./hooks/content_assistant_turnstile.mjs";

function createClassList(initial = []) {
  const classes = new Set(initial);

  return {
    add(value) {
      classes.add(value);
    },
    remove(value) {
      classes.delete(value);
    },
    toggle(value, enabled) {
      if (enabled) {
        classes.add(value);
      } else {
        classes.delete(value);
      }
    },
    contains(value) {
      return classes.has(value);
    },
  };
}

function createMockElement({ id, dataset = {}, hidden = false, value = "", form = null } = {}) {
  return {
    id,
    dataset,
    value,
    textContent: "",
    disabled: false,
    attributes: new Map(),
    listeners: new Map(),
    classList: createClassList(hidden ? ["hidden"] : []),
    addEventListener(name, handler) {
      this.listeners.set(name, handler);
    },
    removeEventListener(name) {
      this.listeners.delete(name);
    },
    dispatch(name, event = {}) {
      const handler = this.listeners.get(name);
      if (handler) {
        handler(event);
      }
    },
    setAttribute(name, valueRef) {
      this.attributes.set(name, valueRef);
    },
    getAttribute(name) {
      return this.attributes.get(name);
    },
    closest(selector) {
      if (selector === "form") {
        return form;
      }

      return null;
    },
  };
}

function createMockDocument(elementsById) {
  return {
    visibilityState: "visible",
    listeners: new Map(),
    getElementById(id) {
      return elementsById.get(id) || null;
    },
    addEventListener(name, handler) {
      this.listeners.set(name, handler);
    },
    removeEventListener(name) {
      this.listeners.delete(name);
    },
    dispatch(name, event) {
      const handler = this.listeners.get(name);
      if (handler) {
        handler(event);
      }
    },
  };
}

function mountHook({ el, documentRef, windowRef, loader, registeredEvents }) {
  const hook = createContentAssistantTurnstileHook({ documentRef, windowRef, loader });
  const context = {
    ...hook,
    el,
    handleEvent(name, callback) {
      registeredEvents.set(name, callback);
    },
  };

  context.mounted();
  return context;
}

test("loads Turnstile only after the modal opens and only once", async () => {
  const registeredEvents = new Map();
  const form = createMockElement({ id: "assistant-form" });
  const modal = createMockElement({ id: "assistant-modal", hidden: true });
  const input = createMockElement({ id: "assistant-turnstile-token" });
  const submit = createMockElement({ id: "assistant-submit" });
  const status = createMockElement({ id: "assistant-turnstile-status" });
  const retry = createMockElement({ id: "assistant-turnstile-retry" });
  const widget = createMockElement({
    id: "assistant-turnstile",
    dataset: {
      siteKey: "site-key",
      inputId: input.id,
      modalId: modal.id,
      loadTrigger: "modal-open",
      submitId: submit.id,
      statusId: status.id,
      retryId: retry.id,
      appearance: "interaction-only",
      size: "invisible",
      execution: "execute",
    },
    form,
  });

  const elements = new Map([
    [modal.id, modal],
    [input.id, input],
    [submit.id, submit],
    [status.id, status],
    [retry.id, retry],
    [widget.id, widget],
  ]);

  const documentRef = createMockDocument(elements);
  const turnstile = {
    renderCalls: 0,
    executeCalls: 0,
    resetCalls: 0,
    render(_element, options) {
      this.renderCalls += 1;
      this.options = options;
      return "widget-1";
    },
    execute() {
      this.executeCalls += 1;
    },
    reset() {
      this.resetCalls += 1;
    },
    remove() {},
  };

  let loadCalls = 0;
  const loader = {
    async load() {
      loadCalls += 1;
      windowRef.turnstile = turnstile;
      return turnstile;
    },
  };

  const windowRef = { turnstile: null };

  mountHook({ el: widget, documentRef, windowRef, loader, registeredEvents });

  assert.equal(loadCalls, 0);
  assert.equal(submit.disabled, true);

  modal.classList.remove("hidden");
  documentRef.dispatch("agent-jido:modal-opened", { target: modal });
  await Promise.resolve();
  await Promise.resolve();

  assert.equal(loadCalls, 1);
  assert.equal(turnstile.renderCalls, 1);
  assert.equal(turnstile.executeCalls, 1);

  documentRef.dispatch("agent-jido:modal-opened", { target: modal });
  await Promise.resolve();

  assert.equal(loadCalls, 1);
  turnstile.options.callback("token-123");

  assert.equal(input.value, "token-123");
  assert.equal(submit.disabled, false);

  registeredEvents.get("content_assistant_turnstile_reset")({ id: widget.id });
  assert.equal(turnstile.resetCalls, 1);
});

test("keeps submit blocked on load failure until retry succeeds", async () => {
  const registeredEvents = new Map();
  const form = createMockElement({ id: "assistant-form" });
  const input = createMockElement({ id: "assistant-turnstile-token" });
  const submit = createMockElement({ id: "assistant-submit" });
  const status = createMockElement({ id: "assistant-turnstile-status" });
  const retry = createMockElement({ id: "assistant-turnstile-retry" });
  const widget = createMockElement({
    id: "assistant-turnstile",
    dataset: {
      siteKey: "site-key",
      inputId: input.id,
      loadTrigger: "mount",
      submitId: submit.id,
      statusId: status.id,
      retryId: retry.id,
      appearance: "interaction-only",
      size: "invisible",
      execution: "execute",
    },
    form,
  });

  const elements = new Map([
    [input.id, input],
    [submit.id, submit],
    [status.id, status],
    [retry.id, retry],
    [widget.id, widget],
  ]);

  const documentRef = createMockDocument(elements);
  const turnstile = {
    render(_element, options) {
      this.options = options;
      return "widget-2";
    },
    execute() {},
    reset() {},
    remove() {},
  };

  let attempts = 0;
  const windowRef = { turnstile: null };
  const loader = {
    async load() {
      attempts += 1;

      if (attempts === 1) {
        throw new Error("network failure");
      }

      windowRef.turnstile = turnstile;
      return turnstile;
    },
  };

  mountHook({ el: widget, documentRef, windowRef, loader, registeredEvents });
  await Promise.resolve();
  await Promise.resolve();

  assert.equal(submit.disabled, true);
  assert.equal(status.textContent, TURNSTILE_ERROR_MESSAGE);
  assert.equal(retry.classList.contains("hidden"), false);

  retry.dispatch("click", { preventDefault() {} });
  await Promise.resolve();
  await Promise.resolve();

  turnstile.options.callback("token-456");

  assert.equal(attempts, 2);
  assert.equal(input.value, "token-456");
  assert.equal(submit.disabled, false);
  assert.equal(retry.classList.contains("hidden"), true);
});
