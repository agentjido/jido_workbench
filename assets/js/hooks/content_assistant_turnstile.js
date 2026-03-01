const ContentAssistantTurnstile = {
  mounted() {
    this.siteKey = this.el.dataset.siteKey || "";
    this.inputId = this.el.dataset.inputId || "";
    this.appearance = this.el.dataset.appearance || "interaction-only";
    this.size = this.el.dataset.size || "invisible";
    this.execution = this.el.dataset.execution || "execute";
    this.widgetId = null;

    this.renderWidget = this.renderWidget.bind(this);
    this.resetRequested = ({ id }) => {
      if (id === this.el.id) {
        this.resetWidget();
      }
    };

    this.handleEvent("content_assistant_turnstile_reset", this.resetRequested);
    this.renderWidget();
  },

  updated() {
    this.siteKey = this.el.dataset.siteKey || this.siteKey;
    this.inputId = this.el.dataset.inputId || this.inputId;
    this.appearance = this.el.dataset.appearance || this.appearance;
    this.size = this.el.dataset.size || this.size;
    this.execution = this.el.dataset.execution || this.execution;
    this.renderWidget();
  },

  destroyed() {
    if (window.turnstile && this.widgetId !== null) {
      try {
        window.turnstile.remove(this.widgetId);
      } catch (_error) {
        // No-op: widget may already be detached.
      }
    }
  },

  renderWidget() {
    if (!this.siteKey || !window.turnstile || typeof window.turnstile.render !== "function") {
      return;
    }

    if (this.widgetId !== null) {
      return;
    }

    this.widgetId = window.turnstile.render(this.el, {
      sitekey: this.siteKey,
      appearance: this.appearance,
      size: this.size,
      execution: this.execution,
      callback: (token) => this.setToken(token),
      "expired-callback": () => this.setToken(""),
      "error-callback": () => this.setToken(""),
    });

    this.executeWidget();
  },

  resetWidget() {
    this.setToken("");

    if (window.turnstile && this.widgetId !== null) {
      try {
        window.turnstile.reset(this.widgetId);
        this.executeWidget();
      } catch (_error) {
        this.widgetId = null;
        this.renderWidget();
      }
    } else {
      this.widgetId = null;
      this.renderWidget();
    }
  },

  executeWidget() {
    if (!window.turnstile || this.widgetId === null || typeof window.turnstile.execute !== "function") {
      return;
    }

    try {
      window.turnstile.execute(this.widgetId);
    } catch (_error) {
      // No-op: execute can fail during script race conditions.
    }
  },

  setToken(token) {
    const input = document.getElementById(this.inputId);

    if (input) {
      input.value = token || "";
    }
  },
};

export default ContentAssistantTurnstile;
