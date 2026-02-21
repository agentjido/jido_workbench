const ScrollReveal = {
  mounted() {
    this._revealed = false;

    const observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (entry.isIntersecting) {
            entry.target.classList.add("animate-fade-in");
            entry.target.classList.remove("opacity-0");
            this._revealed = true;
            observer.unobserve(entry.target);
          }
        });
      },
      { threshold: 0.1 }
    );

    observer.observe(this.el);
  },

  updated() {
    if (this._revealed) {
      this.el.classList.add("animate-fade-in");
      this.el.classList.remove("opacity-0");
    }
  },
};

export default ScrollReveal;
