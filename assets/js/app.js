import "phoenix_html";
import posthog from "posthog-js";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import ScrollSpy from "./hooks/scroll_spy";
import ScrollReveal from "./hooks/scroll_reveal";
import HashScrollLink from "./hooks/hash_scroll_link";
import ContentAssistantTurnstile from "./hooks/content_assistant_turnstile";
import EcosystemOrbit from "./hooks/ecosystem_orbit";
import { PhoenixBlogHooks } from "../../deps/phoenix_blog/priv/static/editorjs/hook.js";

const ANALYTICS_FLUSH_INTERVAL_MS = 1000;
const POSTHOG_BROWSER_EVENTS = new Set([
  "docs_section_viewed",
  "code_copied",
  "livebook_run_clicked",
  "content_assistant_reference_clicked",
  "content_assistant_answer_link_clicked",
]);

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

function syncUtilityTopBarHeight() {
  const utilityBar = document.getElementById("logged-in-utility-bar");
  const height = utilityBar ? Math.ceil(utilityBar.getBoundingClientRect().height) : 0;

  document.documentElement.style.setProperty("--utility-top-bar-height", `${height}px`);
}

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

function isPlainObject(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function stringLength(value) {
  return typeof value === "string" ? value.length : undefined;
}

function flattenAnalyticsProperties(properties = {}) {
  const normalizedPath = normalizePath(properties.path);
  const metadata = isPlainObject(properties.metadata) ? properties.metadata : {};
  const flattened = {
    ...properties,
    ...metadata,
    path: normalizedPath,
  };

  delete flattened.metadata;

  const queryLength =
    stringLength(flattened.query) ||
    stringLength(flattened.query_text) ||
    stringLength(metadata.query) ||
    stringLength(metadata.query_text);

  const feedbackNoteLength =
    stringLength(flattened.feedback_note) ||
    stringLength(flattened.note) ||
    stringLength(metadata.feedback_note) ||
    stringLength(metadata.note);

  if (queryLength !== undefined) {
    flattened.query_length = queryLength;
  }

  if (feedbackNoteLength !== undefined) {
    flattened.feedback_note_length = feedbackNoteLength;
  }

  delete flattened.query;
  delete flattened.query_text;
  delete flattened.feedback_note;
  delete flattened.note;
  delete flattened.answer_html;
  delete flattened.answer_markdown;
  delete flattened.citations;
  delete flattened.related_queries;

  return flattened;
}

function hashToUnitInterval(value) {
  const input = typeof value === "string" && value.length > 0 ? value : "posthog";
  let hash = 0;

  for (let index = 0; index < input.length; index += 1) {
    hash = (hash * 31 + input.charCodeAt(index)) >>> 0;
  }

  return hash / 0xffffffff;
}

function readPostHogConfig() {
  return isPlainObject(window.__agentJidoPostHog) ? window.__agentJidoPostHog : null;
}

function isPostHogPathEligible(path) {
  const config = readPostHogConfig();
  const normalizedPath = normalizePath(path);

  if (!config) {
    return false;
  }

  const ignoredPrefixes = Array.isArray(config.pathIgnorePrefixes) ? config.pathIgnorePrefixes : [];
  const ignoredExactPaths = Array.isArray(config.pathIgnoreExactPaths) ? config.pathIgnoreExactPaths : [];

  if (ignoredExactPaths.includes(normalizedPath)) {
    return false;
  }

  return !ignoredPrefixes.some((prefix) => normalizedPath.startsWith(prefix));
}

const analyticsQueue = [];
let analyticsFlushTimer = null;

const postHogState = {
  initialized: false,
  replaySampled: false,
  autocaptureConfig: false,
  lastTrackedPath: null,
};

function trackPostHogPageview(path) {
  const normalizedPath = normalizePath(path);

  if (!postHogState.initialized || !isPostHogPathEligible(normalizedPath)) {
    return;
  }

  if (postHogState.lastTrackedPath === normalizedPath) {
    return;
  }

  posthog.register({
    current_path: normalizedPath,
  });

  posthog.capture("$pageview", {
    path: normalizedPath,
    current_path: normalizedPath,
    $current_url: window.location.href,
  });

  postHogState.lastTrackedPath = normalizedPath;
}

function syncPostHogForPath(path, { capturePageview = false } = {}) {
  const config = readPostHogConfig();

  if (!config || !postHogState.initialized) {
    return;
  }

  const normalizedPath = normalizePath(path);
  const eligible = isPostHogPathEligible(normalizedPath);

  posthog.register({
    current_path: normalizedPath,
    session_id: config.sessionId,
  });

  posthog.set_config({
    autocapture: eligible ? postHogState.autocaptureConfig : false,
    capture_pageleave: eligible,
  });

  if (config.sessionReplayEnabled && postHogState.replaySampled && eligible) {
    if (!posthog.sessionRecordingStarted()) {
      posthog.startSessionRecording();
    }
  } else if (posthog.sessionRecordingStarted()) {
    posthog.stopSessionRecording();
  }

  if (capturePageview) {
    trackPostHogPageview(normalizedPath);
  }
}

function initPostHog() {
  const config = readPostHogConfig();

  if (!config || !config.apiKey || !config.distinctId || !config.sessionId) {
    return;
  }

  postHogState.replaySampled =
    Number(config.sessionReplaySampleRate) >= 1 ||
    hashToUnitInterval(config.sessionId) < Number(config.sessionReplaySampleRate || 0);

  postHogState.autocaptureConfig = config.autocaptureEnabled
    ? {
        url_ignorelist: [
          ...(Array.isArray(config.pathIgnorePrefixes) ? config.pathIgnorePrefixes : []),
          ...(Array.isArray(config.pathIgnoreExactPaths) ? config.pathIgnoreExactPaths : []),
        ],
        capture_copied_text: false,
      }
    : false;

  const initialPath = normalizePath(config.currentPath || window.location.pathname);
  const initialPageleaveEnabled = isPostHogPathEligible(initialPath);

  posthog.init(config.apiKey, {
    api_host: config.apiHost,
    ui_host: config.uiHost,
    bootstrap: {
      distinctID: config.distinctId,
      sessionID: config.sessionId,
    },
    autocapture: false,
    capture_pageview: false,
    capture_pageleave: initialPageleaveEnabled,
    disable_session_recording: true,
    mask_all_text: false,
    session_recording: {
      blockClass: config.blockClass || "ph-no-capture",
      maskTextClass: config.maskTextClass || "ph-mask",
      maskAllInputs: config.maskAllInputs !== false,
    },
    loaded(instance) {
      instance.register({
        session_id: config.sessionId,
        current_path: normalizePath(config.currentPath || window.location.pathname),
      });

      postHogState.initialized = true;
      syncPostHogForPath(window.location.pathname, { capturePageview: true });
    },
  });
}

function trackPostHogEvent(eventName, properties = {}) {
  if (!postHogState.initialized || !POSTHOG_BROWSER_EVENTS.has(eventName)) {
    return;
  }

  const normalizedPath = normalizePath(properties.path);

  if (!isPostHogPathEligible(normalizedPath)) {
    return;
  }

  posthog.capture(eventName, flattenAnalyticsProperties(properties));
}

function flushAnalyticsQueue() {
  analyticsFlushTimer = null;

  while (analyticsQueue.length > 0) {
    const payload = analyticsQueue.shift();

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
}

function scheduleAnalyticsFlush() {
  if (analyticsFlushTimer === null) {
    analyticsFlushTimer = setTimeout(flushAnalyticsQueue, ANALYTICS_FLUSH_INTERVAL_MS);
  }
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

  analyticsQueue.push(payload);
  scheduleAnalyticsFlush();
  trackPostHogEvent(eventName, payload.properties);
}

window.__agentJidoTrackEvent = trackAnalyticsEvent;

let Hooks = {
  ...PhoenixBlogHooks,
  ScrollSpy,
  ScrollReveal,
  HashScrollLink,
  ContentAssistantTurnstile,
  EcosystemOrbit,
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
  },
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
  },
};

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");

function shouldConnectLiveSocket() {
  const userAgent = navigator.userAgent || "";
  const automatedUserAgent = userAgent.includes("HeadlessChrome") || userAgent.includes("Lighthouse");

  return !navigator.webdriver && !automatedUserAgent;
}

const liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
});

topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", () => topbar.show(300));
window.addEventListener("phx:page-loading-stop", () => {
  topbar.hide();
  syncUtilityTopBarHeight();
  syncPostHogForPath(window.location.pathname, { capturePageview: true });
});
window.addEventListener("resize", syncUtilityTopBarHeight);

syncUtilityTopBarHeight();
initPostHog();

if (shouldConnectLiveSocket()) {
  liveSocket.connect();
}

window.liveSocket = liveSocket;

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
  if (!target) {
    return false;
  }

  if (target.isContentEditable) {
    return true;
  }

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

document.addEventListener("click", (event) => {
  trackDatasetAnalyticsEvent(event.target);

  const livebookLink = event.target.closest("[data-livebook-run='true']");

  if (livebookLink) {
    trackAnalyticsEvent("livebook_run_clicked", {
      source: livebookLink.dataset.analyticsSource || "docs",
      channel: livebookLink.dataset.analyticsChannel || "quick_links",
      target_url: livebookLink.dataset.analyticsTargetUrl || livebookLink.getAttribute("href"),
      path: window.location.pathname,
      metadata: { surface: "docs_page" },
    });
  }

  const copyButton = event.target.closest("[data-copy-button]");

  if (copyButton) {
    const content = copyButton.getAttribute("data-content");

    navigator.clipboard.writeText(content).then(() => {
      const originalIcon = copyButton.innerHTML;

      copyButton.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5">
        <path fill-rule="evenodd" d="M19.916 4.626a.75.75 0 01.208 1.04l-9 13.5a.75.75 0 01-1.154.114l-6-6a.75.75 0 011.06-1.06l5.353 5.353 8.493-12.739a.75.75 0 011.04-.208z" clip-rule="evenodd" />
      </svg>`;

      setTimeout(() => {
        copyButton.innerHTML = originalIcon;
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
