import "phoenix_html";
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import CopyToClipboard from "./hooks/copy_to_clipboard";
import Highlight from "./hooks/highlight";
import ScrollSpy from "./hooks/scroll_spy";
import ScrollReveal from "./hooks/scroll_reveal";

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
  CopyToClipboard,
  Highlight,
  ScrollSpy,
  ScrollReveal,
};

Hooks.ThemeToggle = {
  mounted() {
    const theme = this.el.dataset.theme;

    this.updateButtonStates();

    this.el.addEventListener("click", () => {
      applyTheme(theme);
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

Hooks.CopyCode = {
  mounted() {
    this.el.addEventListener("click", () => {
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

document.addEventListener("click", (e) => {
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
    });
  }
});
