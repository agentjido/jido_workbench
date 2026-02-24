import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import ScrollSpy from "./hooks/scroll_spy";
import ScrollReveal from "./hooks/scroll_reveal";
import ContentAssistantTurnstile from "./hooks/content_assistant_turnstile";

function applyTheme(theme) {
  if (theme === "light") {
    document.documentElement.classList.add("light");
    document.documentElement.classList.remove("dark");
  } else {
    document.documentElement.classList.remove("light");
    document.documentElement.classList.add("dark");
  }
  localStorage.setItem("theme", theme);
}

let Hooks = {
  ScrollSpy,
  ScrollReveal,
  ContentAssistantTurnstile,
};

Hooks.ThemeToggle = {
  mounted() {
    this.updateButtonStates();
    this.handleClick = () => {
      const isLight = document.documentElement.classList.contains("light");
      const nextTheme = isLight ? "dark" : "light";

      applyTheme(nextTheme);
      this.updateButtonStates();
    };

    this.el.addEventListener("click", this.handleClick);
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleClick);
  },

  updateButtonStates() {
    const isLight = document.documentElement.classList.contains("light");
    const moonIcon = this.el.querySelector("[data-theme-icon='moon']");
    const sunIcon = this.el.querySelector("[data-theme-icon='sun']");

    if (moonIcon && sunIcon) {
      moonIcon.classList.toggle("hidden", isLight);
      sunIcon.classList.toggle("hidden", !isLight);
      this.el.setAttribute("aria-label", isLight ? "Switch to dark mode" : "Switch to light mode");
    }
  }
};

Hooks.ScrollShrink = {
  mounted() {
    this.handleScroll = () => {
      const isScrolled = window.scrollY > 20;
      const header = this.el;
      const nav = header.querySelector("nav");
      const logo = header.querySelector("a > div:first-child");
      const logoText = header.querySelector("a > span:first-of-type");

      if (isScrolled) {
        header.classList.remove("pt-6", "pb-12");
        header.classList.add("pt-2", "pb-2");
        if (nav) {
          nav.classList.remove("py-5");
          nav.classList.add("py-3");
        }
        if (logo) {
          logo.classList.remove("w-7", "h-7", "text-sm");
          logo.classList.add("w-6", "h-6", "text-xs");
        }
        if (logoText) {
          logoText.classList.remove("text-base");
          logoText.classList.add("text-sm");
        }
      } else {
        header.classList.add("pt-6", "pb-12");
        header.classList.remove("pt-2", "pb-2");
        if (nav) {
          nav.classList.add("py-5");
          nav.classList.remove("py-3");
        }
        if (logo) {
          logo.classList.add("w-7", "h-7", "text-sm");
          logo.classList.remove("w-6", "h-6", "text-xs");
        }
        if (logoText) {
          logoText.classList.add("text-base");
          logoText.classList.remove("text-sm");
        }
      }
    };

    window.addEventListener("scroll", this.handleScroll);
    this.handleScroll();
  },

  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
  }
};


let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

liveSocket.connect();

window.liveSocket = liveSocket;

function normalizePath(path) {
  if (typeof path === "string" && path.startsWith("/")) {
    return path;
  }

  return window.location.pathname || "/";
}

function parsePositiveInt(value) {
  const parsed = Number.parseInt(value, 10);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : undefined;
}

function trackAnalyticsEvent(eventName, properties = {}) {
  if (!eventName || typeof eventName !== "string") {
    return;
  }

  const payload = {
    event: eventName,
    properties: {
      ...properties,
      path: normalizePath(properties.path),
    },
  };

  fetch("/analytics/events", {
    method: "POST",
    headers: {
      "content-type": "application/json",
      "x-csrf-token": csrfToken,
    },
    credentials: "same-origin",
    keepalive: true,
    body: JSON.stringify(payload),
  }).catch(() => {});
}

window.__agentJidoTrackEvent = trackAnalyticsEvent;

function trackDatasetAnalyticsEvent(target) {
  const analyticsNode = target.closest("[data-analytics-event]");

  if (!analyticsNode) {
    return;
  }

  trackAnalyticsEvent(analyticsNode.dataset.analyticsEvent, {
    source: analyticsNode.dataset.analyticsSource,
    channel: analyticsNode.dataset.analyticsChannel,
    section_id: analyticsNode.dataset.analyticsSectionId,
    target_url: analyticsNode.dataset.analyticsTargetUrl,
    query_log_id: analyticsNode.dataset.analyticsQueryLogId,
    rank: parsePositiveInt(analyticsNode.dataset.analyticsRank),
    path: window.location.pathname,
  });
}

function isEditableTarget(target) {
  if (!target) return false;
  if (target.isContentEditable) return true;

  const tagName = target.tagName ? target.tagName.toLowerCase() : "";
  return tagName === "input" || tagName === "textarea" || tagName === "select";
}

function openPrimaryNavSearch() {
  const trigger = document.getElementById("primary-nav-content-assistant-trigger");

  if (trigger) {
    trigger.click();
  }
}

document.addEventListener("keydown", (event) => {
  if (event.defaultPrevented || isEditableTarget(event.target)) {
    return;
  }

  const key = event.key.toLowerCase();
  const hasCommandModifier = event.metaKey || event.ctrlKey;

  if (hasCommandModifier && key === "k") {
    event.preventDefault();
    openPrimaryNavSearch();
    return;
  }

  if (!event.metaKey && !event.ctrlKey && !event.altKey && !event.shiftKey && key === "/") {
    event.preventDefault();
    openPrimaryNavSearch();
  }
});

document.addEventListener("click", (e) => {
  trackDatasetAnalyticsEvent(e.target);

  const livebookLink = e.target.closest("[data-livebook-run='true']");
  if (livebookLink) {
    trackAnalyticsEvent("livebook_run_clicked", {
      source: livebookLink.dataset.analyticsSource || "docs",
      channel: livebookLink.dataset.analyticsChannel || "quick_links",
      target_url: livebookLink.dataset.analyticsTargetUrl || livebookLink.getAttribute("href"),
      path: window.location.pathname,
      metadata: { surface: "docs_page" },
    });
  }

  if (e.target.closest("[data-copy-button]")) {
    const button = e.target.closest("[data-copy-button]");
    const content = button.getAttribute("data-content");

    navigator.clipboard.writeText(content).then(() => {
      const originalIcon = button.innerHTML;

      button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5">
        <path fill-rule="evenodd" d="M19.916 4.626a.75.75 0 01.208 1.04l-9 13.5a.75.75 0 01-1.154.114l-6-6a.75.75 0 011.06-1.06l5.353 5.353 8.493-12.739a.75.75 0 011.04-.208z" clip-rule="evenodd" />
      </svg>`;

      setTimeout(() => {
        button.innerHTML = originalIcon;
      }, 2000);

      trackAnalyticsEvent("code_copied", {
        source: "docs",
        channel: "copy_button",
        path: window.location.pathname,
        metadata: {
          surface: "docs_page",
          content_length: content ? content.length : 0,
        },
      });
    });
  }
});
