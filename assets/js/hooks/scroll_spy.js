export default {
  mounted() {
    this.scrollSpyTarget = this.resolveTarget();
    this.navLinks = Array.from(this.el.querySelectorAll("[data-toc-link]"));
    this.activeClasses = ["text-primary", "border-l-primary", "bg-primary/5"];
    this.inactiveClasses = ["text-muted-foreground", "border-l-transparent"];
    this.viewedSectionIds = new Set();

    this.setupSmoothScroll();
    this.setupScrollSpy();
  },

  updated() {
    this.destroyed();
    this.mounted();
  },

  destroyed() {
    if (this.observer) {
      this.observer.disconnect();
      this.observer = null;
    }

    if (this.clickHandlers) {
      this.clickHandlers.forEach(({ anchor, handler }) => {
        anchor.removeEventListener("click", handler);
      });
    }

    this.clickHandlers = [];
    this.navLinks = [];
    this.viewedSectionIds = new Set();
  },

  resolveTarget() {
    const selector = this.el.dataset.scrollSpyTarget;

    if (!selector) {
      return document;
    }

    return document.querySelector(selector) || document;
  },

  setupSmoothScroll() {
    this.clickHandlers = [];

    this.navLinks.forEach((anchor) => {
      const handler = (event) => {
        event.preventDefault();
        const targetId = anchor.getAttribute("href")?.slice(1);
        const targetElement = targetId ? document.getElementById(targetId) : null;

        if (!targetElement) {
          return;
        }

        targetElement.scrollIntoView({
          behavior: "smooth",
          block: "start",
        });

        this.activateLink(anchor);
        history.replaceState(null, "", `#${targetId}`);
      };

      anchor.addEventListener("click", handler);
      this.clickHandlers.push({ anchor, handler });
    });
  },

  setupScrollSpy() {
    const headingsRoot = this.scrollSpyTarget === document ? document : this.scrollSpyTarget;
    const sections = Array.from(headingsRoot.querySelectorAll("h1[id], h2[id], h3[id]"));

    if (sections.length === 0 || this.navLinks.length === 0) {
      return;
    }

    const initialId = window.location.hash?.slice(1);
    if (initialId) {
      const initialLink = this.el.querySelector(`a[href="#${initialId}"]`);
      if (initialLink) {
        this.activateLink(initialLink);
      }
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        const visible = entries
          .filter((entry) => entry.isIntersecting)
          .sort((a, b) => b.intersectionRatio - a.intersectionRatio);

        if (visible.length === 0) {
          return;
        }

        const topEntry =
          visible.find((entry) => entry.boundingClientRect.top >= 0) ||
          visible[0];
        const activeLink = this.el.querySelector(`a[href="#${topEntry.target.id}"]`);

        if (activeLink) {
          this.activateLink(activeLink);
        }
      },
      {
        root: null,
        rootMargin: "-18% 0px -68% 0px",
        threshold: [0.1, 0.4, 0.7],
      }
    );

    sections.forEach((section) => this.observer.observe(section));
  },

  activateLink(activeLink) {
    this.navLinks.forEach((link) => {
      if (link === activeLink) {
        this.inactiveClasses.forEach((klass) => link.classList.remove(klass));
        this.activeClasses.forEach((klass) => link.classList.add(klass));
      } else {
        this.activeClasses.forEach((klass) => link.classList.remove(klass));
        this.inactiveClasses.forEach((klass) => link.classList.add(klass));
      }
    });

    this.trackSectionView(activeLink);
  },

  trackSectionView(activeLink) {
    const targetId = activeLink?.getAttribute("href")?.slice(1);

    if (!targetId || this.viewedSectionIds.has(targetId)) {
      return;
    }

    this.viewedSectionIds.add(targetId);

    if (typeof window.__agentJidoTrackEvent === "function") {
      window.__agentJidoTrackEvent("docs_section_viewed", {
        source: "docs",
        channel: "right_toc",
        section_id: targetId,
        path: window.location.pathname,
        metadata: { surface: "docs_page" },
      });
    }
  },
};
