const AskAiTurnstile = {
  mounted() {
    this.siteKey = this.el.dataset.siteKey || "";
    this.inputId = this.el.dataset.inputId || "";
    this.widgetId = null;

    this.renderWidget = this.renderWidget.bind(this);
    this.resetRequested = ({ id }) => {
      if (id === this.el.id) {
        this.resetWidget();
      }
    };

    this.handleEvent("ask_ai_turnstile_reset", this.resetRequested);
    this.renderWidget();
  },

  updated() {
    this.siteKey = this.el.dataset.siteKey || this.siteKey;
    this.inputId = this.el.dataset.inputId || this.inputId;
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
      callback: (token) => this.setToken(token),
      "expired-callback": () => this.setToken(""),
      "error-callback": () => this.setToken(""),
    });
  },

  resetWidget() {
    this.setToken("");

    if (window.turnstile && this.widgetId !== null) {
      try {
        window.turnstile.reset(this.widgetId);
      } catch (_error) {
        this.widgetId = null;
        this.renderWidget();
      }
    } else {
      this.widgetId = null;
      this.renderWidget();
    }
  },

  setToken(token) {
    const input = document.getElementById(this.inputId);

    if (input) {
      input.value = token || "";
    }
  },
};

export default AskAiTurnstile;
