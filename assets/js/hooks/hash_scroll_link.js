const HashScrollLink = {
  mounted() {
    this.handleClick = (event) => {
      const href = this.el.getAttribute("href") || "";

      if (!href.startsWith("#")) {
        return;
      }

      const targetId = href.slice(1);
      const target = targetId ? document.getElementById(targetId) : null;

      if (!target) {
        return;
      }

      event.preventDefault();

      target.scrollIntoView({
        behavior: "smooth",
        block: "start",
      });

      history.replaceState(null, "", `#${targetId}`);
    };

    this.el.addEventListener("click", this.handleClick);
  },

  destroyed() {
    if (this.handleClick) {
      this.el.removeEventListener("click", this.handleClick);
    }
  },
};

export default HashScrollLink;
