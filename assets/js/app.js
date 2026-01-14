// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Initialize theme on page load
(function() {
  const stored = localStorage.getItem('theme');
  const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
  
  if (stored === 'light' || (!stored && !prefersDark)) {
    document.documentElement.classList.add('light');
  } else {
    document.documentElement.classList.remove('light');
  }
})();

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import CopyToClipboard from "./hooks/copy_to_clipboard";
import Highlight from "./hooks/highlight";
import ColorSchemeHook from "./hooks/color-scheme-hook";
import ScrollSpy from "./hooks/scroll_spy";
import ScrollReveal from "./hooks/scroll_reveal";

let Hooks = {
  CopyToClipboard,
  Highlight,
  ColorSchemeHook,
  ScrollSpy,
  ScrollReveal,
};

// Theme Toggle Hook
Hooks.ThemeToggle = {
  mounted() {
    const theme = this.el.dataset.theme;
    
    // Initialize button state from current theme
    this.updateButtonStates();
    
    this.el.addEventListener("click", () => {
      const isDark = theme === "dark";
      if (isDark) {
        document.documentElement.classList.remove("light");
        localStorage.setItem("theme", "dark");
      } else {
        document.documentElement.classList.add("light");
        localStorage.setItem("theme", "light");
      }
      this.updateButtonStates();
    });
  },
  
  updateButtonStates() {
    const isLight = document.documentElement.classList.contains("light");
    const darkBtn = document.getElementById("theme-dark-btn");
    const lightBtn = document.getElementById("theme-light-btn");
    
    if (darkBtn && lightBtn) {
      if (isLight) {
        darkBtn.className = "px-3 py-1.5 rounded text-[10px] font-semibold transition-colors text-muted-foreground hover:text-foreground";
        lightBtn.className = "px-3 py-1.5 rounded text-[10px] font-semibold transition-colors bg-primary text-primary-foreground";
      } else {
        darkBtn.className = "px-3 py-1.5 rounded text-[10px] font-semibold transition-colors bg-primary text-primary-foreground";
        lightBtn.className = "px-3 py-1.5 rounded text-[10px] font-semibold transition-colors text-muted-foreground hover:text-foreground";
      }
    }
  }
}

// Scroll Shrink Hook for header
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
    this.handleScroll(); // Initial check
  },
  
  destroyed() {
    window.removeEventListener("scroll", this.handleScroll);
  }
}

// Scroll Reveal Hook for sections
Hooks.ScrollReveal = {
  mounted() {
    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.remove("opacity-0");
            entry.target.classList.add("animate-fade-in");
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1 }
    );
    
    observer.observe(this.el);
  }
}

// Copy Code Hook
Hooks.CopyCode = {
  mounted() {
    this.el.addEventListener("click", () => {
      // Find the code content - look for data-content attribute or sibling pre/code
      let content = this.el.dataset.content;
      
      if (!content) {
        const codeBlock = this.el.closest(".code-block");
        if (codeBlock) {
          const codeElement = codeBlock.querySelector("pre code") || codeBlock.querySelector("pre");
          if (codeElement) {
            content = codeElement.textContent;
          }
        }
      }
      
      if (content) {
        navigator.clipboard.writeText(content).then(() => {
          const originalText = this.el.textContent;
          this.el.textContent = "COPIED!";
          setTimeout(() => {
            this.el.textContent = originalText;
          }, 2000);
        });
      }
    });
  }
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  hooks: Hooks,
  params: { _csrf_token: csrfToken },
  dom: {
    onBeforeElUpdated(from, to) {
      if (from._x_dataStack) {
        window.Alpine.clone(from, to);
      }
    },
  },
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Theme toggle functionality for Jido marketing pages
const THEME_STORAGE_KEY = "jido-theme";

function applyStoredTheme() {
  const html = document.documentElement;
  const stored = localStorage.getItem(THEME_STORAGE_KEY);
  if (stored === "light") {
    html.classList.add("light");
  } else {
    html.classList.remove("light");
  }
}

// Apply theme on initial load
applyStoredTheme();

// Global toggle function
window.toggleJidoTheme = function () {
  const html = document.documentElement;
  const isLight = html.classList.toggle("light");
  localStorage.setItem(THEME_STORAGE_KEY, isLight ? "light" : "dark");
};

// Add copy to clipboard functionality
document.addEventListener("click", (e) => {
  if (e.target.closest("[data-copy-button]")) {
    const button = e.target.closest("[data-copy-button]");
    const content = button.getAttribute("data-content");

    navigator.clipboard.writeText(content).then(() => {
      // Store the original icon HTML
      const originalIcon = button.innerHTML;

      // Replace with checkmark icon
      button.innerHTML = `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="currentColor" class="w-5 h-5">
        <path fill-rule="evenodd" d="M19.916 4.626a.75.75 0 01.208 1.04l-9 13.5a.75.75 0 01-1.154.114l-6-6a.75.75 0 011.06-1.06l5.353 5.353 8.493-12.739a.75.75 0 011.04-.208z" clip-rule="evenodd" />
      </svg>`;

      // Restore original icon after 2 seconds
      setTimeout(() => {
        button.innerHTML = originalIcon;
      }, 2000);
    });
  }
});
