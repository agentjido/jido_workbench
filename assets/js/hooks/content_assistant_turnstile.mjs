export const TURNSTILE_SCRIPT_SRC = "https://challenges.cloudflare.com/turnstile/v0/api.js?render=explicit";
export const TURNSTILE_READY_MESSAGE = "Verification runs in the background and only prompts when risk is detected.";
export const TURNSTILE_LOADING_MESSAGE = "Preparing verification challenge...";
export const TURNSTILE_VERIFYING_MESSAGE = "Running verification in the background...";
export const TURNSTILE_REFRESHING_MESSAGE = "Refreshing verification...";
export const TURNSTILE_ERROR_MESSAGE = "Verification could not load. Retry to continue.";

let sharedTurnstileLoader = null;

function supportsClassList(element) {
  return element?.classList && typeof element.classList.toggle === "function";
}

function toggleClass(element, className, enabled) {
  if (!supportsClassList(element)) {
    return;
  }

  element.classList.toggle(className, enabled);
}

export function createTurnstileLoader({
  windowRef,
  documentRef,
  scriptSrc = TURNSTILE_SCRIPT_SRC,
  timeoutMs = 10_000,
  setTimeoutFn,
  clearTimeoutFn,
} = {}) {
  const timeout = typeof setTimeoutFn === "function" ? setTimeoutFn : setTimeout;
  const clearTimeoutRef = typeof clearTimeoutFn === "function" ? clearTimeoutFn : clearTimeout;

  let pendingPromise = null;

  function turnstileReady() {
    return Boolean(windowRef?.turnstile && typeof windowRef.turnstile.render === "function");
  }

  function resolveScriptElement() {
    if (!documentRef?.querySelector) {
      return null;
    }

    return documentRef.querySelector("script[data-agent-jido-turnstile-script='true']");
  }

  function appendScriptElement() {
    if (!documentRef?.createElement || !documentRef?.head?.appendChild) {
      return null;
    }

    const script = documentRef.createElement("script");
    script.src = scriptSrc;
    script.async = true;
    script.defer = true;
    script.setAttribute("data-agent-jido-turnstile-script", "true");
    documentRef.head.appendChild(script);
    return script;
  }

  function load() {
    if (turnstileReady()) {
      return Promise.resolve(windowRef.turnstile);
    }

    if (pendingPromise) {
      return pendingPromise;
    }

    pendingPromise = new Promise((resolve, reject) => {
      const script = resolveScriptElement() || appendScriptElement();
      let timeoutId = null;
      let pollId = null;

      const cleanup = () => {
        if (timeoutId !== null) {
          clearTimeoutRef(timeoutId);
          timeoutId = null;
        }

        if (pollId !== null) {
          clearTimeoutRef(pollId);
          pollId = null;
        }

        if (script?.removeEventListener) {
          script.removeEventListener("load", handleLoad);
          script.removeEventListener("error", handleError);
        }
      };

      const resolveReady = () => {
        if (turnstileReady()) {
          cleanup();
          pendingPromise = null;
          resolve(windowRef.turnstile);
          return true;
        }

        return false;
      };

      const handleError = () => {
        cleanup();
        pendingPromise = null;
        reject(new Error("Turnstile failed to load"));
      };

      const pollForReady = () => {
        if (resolveReady()) {
          return;
        }

        pollId = timeout(pollForReady, 50);
      };

      const handleLoad = () => {
        if (!resolveReady()) {
          pollForReady();
        }
      };

      timeoutId = timeout(handleError, timeoutMs);

      if (!script) {
        handleError();
        return;
      }

      if (script.addEventListener) {
        script.addEventListener("load", handleLoad);
        script.addEventListener("error", handleError);
      }

      handleLoad();
    });

    return pendingPromise;
  }

  return { load };
}

function resolveSharedLoader(windowRef, documentRef) {
  if (!sharedTurnstileLoader) {
    sharedTurnstileLoader = createTurnstileLoader({ windowRef, documentRef });
  }

  return sharedTurnstileLoader;
}

export function resetSharedTurnstileLoaderForTests() {
  sharedTurnstileLoader = null;
}

export function createContentAssistantTurnstileHook({
  windowRef,
  documentRef,
  loader,
} = {}) {
  return {
    mounted() {
      this.windowRef = windowRef;
      this.documentRef = documentRef;
      this.loader = loader || resolveSharedLoader(this.windowRef, this.documentRef);
      this.widgetId = null;
      this.loadingPromise = null;
      this.submitBlocked = false;
      this.retryButton = null;
      this.formElement = null;

      this.resetRequested = ({ id }) => {
        if (id === this.el.id) {
          this.resetWidget();
        }
      };

      this.handleModalOpened = (event) => {
        const eventTargetId = event?.target?.id || event?.detail?.id;

        if (this.loadTrigger === "modal-open" && eventTargetId === this.modalId) {
          void this.ensureWidget();
        }
      };

      this.handleRetryClick = (event) => {
        event.preventDefault();
        void this.retryWidget();
      };

      this.handleSubmit = (event) => {
        if (this.hasToken()) {
          return;
        }

        event.preventDefault();
        void this.ensureWidget();
      };

      this.readDataset();
      this.bindElements();
      this.applyBlockedState(true);
      this.setStatus("loading", TURNSTILE_LOADING_MESSAGE);

      this.handleEvent("content_assistant_turnstile_reset", this.resetRequested);
      this.documentRef?.addEventListener("agent-jido:modal-opened", this.handleModalOpened);

      if (this.shouldLoadImmediately()) {
        void this.ensureWidget();
      }
    },

    updated() {
      this.readDataset();
      this.bindElements();

      if (this.shouldLoadImmediately()) {
        void this.ensureWidget();
      }
    },

    destroyed() {
      this.detachElementListeners();
      this.documentRef?.removeEventListener("agent-jido:modal-opened", this.handleModalOpened);

      if (this.windowRef?.turnstile && this.widgetId !== null) {
        try {
          this.windowRef.turnstile.remove(this.widgetId);
        } catch (_error) {
          // Widget may already be detached.
        }
      }
    },

    readDataset() {
      this.siteKey = this.el.dataset.siteKey || "";
      this.inputId = this.el.dataset.inputId || "";
      this.appearance = this.el.dataset.appearance || "interaction-only";
      this.size = this.el.dataset.size || "invisible";
      this.execution = this.el.dataset.execution || "execute";
      this.modalId = this.el.dataset.modalId || "";
      this.loadTrigger = this.el.dataset.loadTrigger || "mount";
      this.submitId = this.el.dataset.submitId || "";
      this.statusId = this.el.dataset.statusId || "";
      this.retryId = this.el.dataset.retryId || "";
    },

    bindElements() {
      this.inputElement = this.inputId ? this.documentRef?.getElementById(this.inputId) : null;
      this.submitButton = this.submitId ? this.documentRef?.getElementById(this.submitId) : null;
      this.statusElement = this.statusId ? this.documentRef?.getElementById(this.statusId) : null;
      this.nextRetryButton = this.retryId ? this.documentRef?.getElementById(this.retryId) : null;
      this.nextFormElement = typeof this.el.closest === "function" ? this.el.closest("form") : null;

      if (this.retryButton !== this.nextRetryButton || this.formElement !== this.nextFormElement) {
        this.detachElementListeners();
        this.retryButton = this.nextRetryButton;
        this.formElement = this.nextFormElement;
        this.attachElementListeners();
      } else {
        this.retryButton = this.nextRetryButton;
        this.formElement = this.nextFormElement;
      }

      this.applyBlockedState(this.submitBlocked);
    },

    attachElementListeners() {
      if (typeof this.handleRetryClick === "function") {
        this.retryButton?.addEventListener("click", this.handleRetryClick);
      }

      if (typeof this.handleSubmit === "function") {
        this.formElement?.addEventListener("submit", this.handleSubmit);
      }
    },

    detachElementListeners() {
      if (typeof this.handleRetryClick === "function") {
        this.retryButton?.removeEventListener("click", this.handleRetryClick);
      }

      if (typeof this.handleSubmit === "function") {
        this.formElement?.removeEventListener("submit", this.handleSubmit);
      }
    },

    shouldLoadImmediately() {
      if (this.loadTrigger !== "modal-open") {
        return true;
      }

      const modalElement = this.modalId ? this.documentRef?.getElementById(this.modalId) : null;
      return modalElement ? !modalElement.classList?.contains("hidden") : false;
    },

    hasToken() {
      return Boolean(this.inputElement?.value);
    },

    setStatus(state, message) {
      if (this.statusElement) {
        this.statusElement.dataset.state = state;
        this.statusElement.textContent = message;
      }

      if (this.retryButton) {
        toggleClass(this.retryButton, "hidden", state !== "error");
      }
    },

    applyBlockedState(blocked) {
      this.submitBlocked = blocked;

      if (!this.submitButton) {
        return;
      }

      this.submitButton.disabled = blocked;
      this.submitButton.setAttribute("aria-disabled", blocked ? "true" : "false");
      toggleClass(this.submitButton, "opacity-60", blocked);
      toggleClass(this.submitButton, "cursor-not-allowed", blocked);
    },

    setToken(token) {
      if (this.inputElement) {
        this.inputElement.value = token || "";
      }

      if (token) {
        this.applyBlockedState(false);
        this.setStatus("ready", TURNSTILE_READY_MESSAGE);
      } else if (this.widgetId !== null) {
        this.applyBlockedState(true);
      }
    },

    async ensureWidget() {
      if (!this.siteKey || this.widgetId !== null || this.loadingPromise) {
        if (this.widgetId !== null) {
          this.executeWidget();
        }

        return;
      }

      this.applyBlockedState(true);
      this.setStatus("loading", TURNSTILE_LOADING_MESSAGE);

      this.loadingPromise = this.loader
        .load()
        .then((turnstile) => {
          this.loadingPromise = null;
          this.renderWidget(turnstile);
        })
        .catch(() => {
          this.loadingPromise = null;
          this.setToken("");
          this.applyBlockedState(true);
          this.setStatus("error", TURNSTILE_ERROR_MESSAGE);
        });

      await this.loadingPromise;
    },

    renderWidget(turnstile) {
      if (!turnstile || typeof turnstile.render !== "function" || this.widgetId !== null) {
        return;
      }

      this.widgetId = turnstile.render(this.el, {
        sitekey: this.siteKey,
        appearance: this.appearance,
        size: this.size,
        execution: this.execution,
        callback: (token) => this.setToken(token),
        "expired-callback": () => {
          this.setToken("");
          this.setStatus("loading", TURNSTILE_REFRESHING_MESSAGE);
          this.executeWidget();
        },
        "error-callback": () => {
          this.setToken("");
          this.applyBlockedState(true);
          this.setStatus("error", TURNSTILE_ERROR_MESSAGE);
        },
      });

      this.setStatus("verifying", TURNSTILE_VERIFYING_MESSAGE);
      this.executeWidget();
    },

    executeWidget() {
      if (!this.windowRef?.turnstile || this.widgetId === null || typeof this.windowRef.turnstile.execute !== "function") {
        return;
      }

      try {
        this.applyBlockedState(true);
        this.setStatus("verifying", TURNSTILE_VERIFYING_MESSAGE);
        this.windowRef.turnstile.execute(this.widgetId);
      } catch (_error) {
        this.applyBlockedState(true);
        this.setStatus("error", TURNSTILE_ERROR_MESSAGE);
      }
    },

    async retryWidget() {
      if (this.widgetId !== null) {
        this.resetWidget();
        return;
      }

      await this.ensureWidget();
    },

    resetWidget() {
      this.setToken("");
      this.setStatus("loading", TURNSTILE_REFRESHING_MESSAGE);

      if (this.windowRef?.turnstile && this.widgetId !== null) {
        try {
          this.windowRef.turnstile.reset(this.widgetId);
          this.executeWidget();
          return;
        } catch (_error) {
          this.widgetId = null;
        }
      }

      void this.ensureWidget();
    },
  };
}

const ContentAssistantTurnstile = createContentAssistantTurnstileHook({
  windowRef: typeof window === "undefined" ? null : window,
  documentRef: typeof document === "undefined" ? null : document,
});

export default ContentAssistantTurnstile;
