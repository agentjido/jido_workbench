const CENTER_X = 500;
const CENTER_Y = 500;
const VIEWBOX = "-20 -20 1040 1040";

const RINGS = {
  foundation: 160,
  ai: 295,
  app: 430,
};

const RING_CONFIG = {
  foundation: { speed: 0.00009, dir: 1 },
  ai: { speed: 0.00006, dir: -1 },
  app: { speed: 0.000035, dir: 1 },
};

const LAYER_COLORS = {
  foundation: "#5BC8F5",
  core: "#4EEEB4",
  ai: "#F5C842",
  app: "#E87DE8",
};

const DOMAIN_COLORS = {
  core: "#4EEEB4",
  ai: "#5BC8F5",
  tools: "#F5C842",
  runtime: "#7BF57B",
  integrations: "#E87DE8",
  foundation: "#5BC8F5",
  app: "#E87DE8",
};

const DOMAIN_FALLBACK_COLORS = [
  "#4EEEB4",
  "#5BC8F5",
  "#F5C842",
  "#E87DE8",
  "#F57070",
  "#7BF57B",
  "#C49BFF",
  "#FF9F5A",
];

const LAYER_BUTTONS = ["all", "core", "foundation", "ai", "app"];

const STAR_COUNT = 160;

function clamp(value, min, max) {
  return Math.max(min, Math.min(max, value));
}

function asNumber(value) {
  if (value === null || value === undefined || value === "") {
    return null;
  }

  const parsed = Number(value);
  return Number.isFinite(parsed) ? parsed : null;
}

function normalizeLayer(layer) {
  if (layer === "foundation" || layer === "core" || layer === "ai" || layer === "app") {
    return layer;
  }

  return "app";
}

function toTitleCase(value) {
  return String(value || "")
    .replace(/_/g, " ")
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(" ");
}

function escapeHtml(value) {
  return String(value || "")
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

function createStars() {
  return Array.from({ length: STAR_COUNT }, () => ({
    cx: Math.random() * 1040 - 20,
    cy: Math.random() * 1040 - 20,
    r: Math.random() * 0.9 + 0.2,
    o: Math.random() * 0.3 + 0.05,
  }));
}

function normalizePayload(raw) {
  if (!raw) {
    return { centerId: null, packages: [], domains: [] };
  }

  let parsed;

  try {
    parsed = JSON.parse(raw);
  } catch (_err) {
    return { centerId: null, packages: [], domains: [] };
  }

  const seenIds = new Set();
  const packages = [];
  const rawPackages = Array.isArray(parsed.packages) ? parsed.packages : [];

  rawPackages.forEach((item) => {
    if (!item || typeof item.id !== "string" || item.id.trim() === "") {
      return;
    }

    if (item.visible === false) {
      return;
    }

    if (seenIds.has(item.id)) {
      return;
    }

    seenIds.add(item.id);

    const layer = normalizeLayer(item.layer);
    const domain = String(item.domain || item.category || layer || "app");

    packages.push({
      id: item.id,
      name: String(item.name || item.id),
      title: String(item.title || item.name || item.id),
      label: String(item.label || item.graph_label || item.name || item.id),
      path: String(item.path || `/ecosystem/${item.id}`),
      layer,
      category: String(item.category || ""),
      domain,
      maturity: String(item.maturity || "experimental"),
      deps: Array.isArray(item.deps) ? item.deps.filter((dep) => typeof dep === "string" && dep !== item.id) : [],
      order: asNumber(item.order),
      weight: asNumber(item.weight),
      visible: item.visible !== false,
    });
  });

  const packageIds = new Set(packages.map((pkg) => pkg.id));
  packages.forEach((pkg) => {
    pkg.deps = pkg.deps.filter((dep) => packageIds.has(dep));
  });

  const domainLabels = new Map();
  if (Array.isArray(parsed.domains)) {
    parsed.domains.forEach((domain) => {
      if (!domain || typeof domain.id !== "string") {
        return;
      }
      domainLabels.set(domain.id, String(domain.label || toTitleCase(domain.id)));
    });
  }

  const centerIdFromPayload = typeof parsed.center_id === "string" ? parsed.center_id : null;
  const firstCore = packages.find((pkg) => pkg.layer === "core");
  const centerId = packageIds.has(centerIdFromPayload) ? centerIdFromPayload : firstCore ? firstCore.id : null;

  const domains = [...new Set(packages.map((pkg) => pkg.domain))]
    .sort((a, b) => {
      const aLabel = domainLabels.get(a) || toTitleCase(a);
      const bLabel = domainLabels.get(b) || toTitleCase(b);
      return aLabel.localeCompare(bLabel);
    })
    .map((id) => ({ id, label: domainLabels.get(id) || toTitleCase(id) }));

  return { centerId, packages, domains };
}

function computeModel(data) {
  const packageById = Object.create(null);
  data.packages.forEach((pkg) => {
    packageById[pkg.id] = pkg;
  });

  const depsById = Object.create(null);
  data.packages.forEach((pkg) => {
    depsById[pkg.id] = pkg.deps;
  });

  const dependentCounts = Object.create(null);
  data.packages.forEach((pkg) => {
    dependentCounts[pkg.id] = 0;
  });
  Object.values(depsById).forEach((deps) => {
    deps.forEach((depId) => {
      dependentCounts[depId] = (dependentCounts[depId] || 0) + 1;
    });
  });

  const centerId = data.centerId;
  const centerPackage = centerId ? packageById[centerId] : null;

  const orbitPackages = data.packages.filter((pkg) => pkg.id !== centerId && pkg.layer !== "core");
  const grouped = Object.create(null);
  orbitPackages.forEach((pkg) => {
    const layer = pkg.layer === "foundation" || pkg.layer === "ai" || pkg.layer === "app" ? pkg.layer : "app";
    if (!grouped[layer]) {
      grouped[layer] = [];
    }
    grouped[layer].push(pkg);
  });

  Object.keys(grouped).forEach((key) => {
    grouped[key].sort((a, b) => {
      const aOrder = Number.isFinite(a.order) ? a.order : 9_999;
      const bOrder = Number.isFinite(b.order) ? b.order : 9_999;
      if (aOrder !== bOrder) {
        return aOrder - bOrder;
      }
      return a.name.localeCompare(b.name);
    });
  });

  const phaseByLayer = {
    foundation: -Math.PI / 2,
    ai: -Math.PI / 2 - Math.PI / 6,
    app: -Math.PI / 2 + Math.PI / 9,
  };

  const nodes = [];
  Object.entries(grouped).forEach(([layer, group]) => {
    const total = Math.max(group.length, 1);
    const step = (Math.PI * 2) / total;
    const phase = phaseByLayer[layer] || -Math.PI / 2;

    group.forEach((pkg, index) => {
      const dependentCount = dependentCounts[pkg.id] || 0;
      const computedRadius = clamp(9 + dependentCount * 2.4, 9, 22);
      const radius = Number.isFinite(pkg.weight) ? clamp(pkg.weight, 8, 30) : computedRadius;

      nodes.push({
        ...pkg,
        ring: RINGS[pkg.layer] || RINGS.app,
        baseAngle: phase + index * step,
        radius,
      });
    });
  });

  const nodeById = Object.create(null);
  nodes.forEach((node) => {
    nodeById[node.id] = node;
  });

  return {
    centerId,
    centerPackage,
    domains: data.domains,
    packageById,
    depsById,
    dependentCounts,
    nodes,
    nodeById,
  };
}

function domainColor(domainId, index) {
  return DOMAIN_COLORS[domainId] || DOMAIN_FALLBACK_COLORS[index % DOMAIN_FALLBACK_COLORS.length];
}

const EcosystemOrbit = {
  mounted() {
    this.stars = createStars();
    this.raf = null;
    this.lastTs = null;
    this.state = {
      timeMs: 0,
      paused: false,
      focusLayer: null,
      selectedId: null,
      hoveredId: null,
      hoverDomain: null,
      dirty: true,
    };

    this.renderShell();
    this.cacheDom();
    this.bindEvents();
    this.syncFromDataset();
    this.startAnimation();
  },

  updated() {
    this.syncFromDataset();
  },

  destroyed() {
    if (this.raf) {
      cancelAnimationFrame(this.raf);
      this.raf = null;
    }

    this.unbindEvents();
  },

  renderShell() {
    this.el.innerHTML = `
      <div class="ecosystem-orbit-shell">
        <div class="ecosystem-orbit-toolbar">
          <div class="ecosystem-orbit-title">
            <span class="ecosystem-orbit-title-main">JIDO ORBIT</span>
            <span class="ecosystem-orbit-title-sub">public package graph</span>
          </div>
          <div class="ecosystem-orbit-controls" data-orbit-controls></div>
        </div>
        <div class="ecosystem-orbit-stage">
          <svg class="ecosystem-orbit-svg" data-orbit-svg viewBox="${VIEWBOX}" preserveAspectRatio="xMidYMid meet"></svg>
        </div>
        <div class="ecosystem-orbit-bottom">
          <div class="ecosystem-orbit-legend" data-orbit-legend></div>
          <div class="ecosystem-orbit-detail" data-orbit-detail></div>
        </div>
      </div>
    `;
  },

  cacheDom() {
    this.controlsEl = this.el.querySelector("[data-orbit-controls]");
    this.legendEl = this.el.querySelector("[data-orbit-legend]");
    this.detailEl = this.el.querySelector("[data-orbit-detail]");
    this.svgEl = this.el.querySelector("[data-orbit-svg]");
  },

  bindEvents() {
    this.handleControlsClick = (event) => {
      const button = event.target.closest("[data-orbit-control]");
      if (!button) return;

      const action = button.dataset.orbitControl;
      if (action === "pause") {
        this.state.paused = !this.state.paused;
        this.markDirty();
        return;
      }

      if (action === "all") {
        this.state.focusLayer = null;
        this.state.selectedId = null;
        this.markDirty();
        return;
      }

      if (action === "core") {
        if (!this.model.centerId) return;
        this.state.focusLayer = null;
        this.state.selectedId = this.state.selectedId === this.model.centerId ? null : this.model.centerId;
        this.markDirty();
        return;
      }

      if (action === "foundation" || action === "ai" || action === "app") {
        this.state.selectedId = null;
        this.state.focusLayer = this.state.focusLayer === action ? null : action;
        this.markDirty();
      }
    };

    this.handleSvgClick = (event) => {
      const node = event.target.closest("[data-node-id]");
      if (node) {
        const id = node.dataset.nodeId;
        this.state.selectedId = this.state.selectedId === id ? null : id;
        this.state.focusLayer = null;
        this.markDirty();
        return;
      }

      const sun = event.target.closest("[data-sun-id]");
      if (sun) {
        const id = sun.dataset.sunId;
        this.state.selectedId = this.state.selectedId === id ? null : id;
        this.state.focusLayer = null;
        this.markDirty();
        return;
      }

      const ring = event.target.closest("[data-ring-layer]");
      if (ring) {
        const layer = ring.dataset.ringLayer;
        this.state.selectedId = null;
        this.state.focusLayer = this.state.focusLayer === layer ? null : layer;
        this.markDirty();
        return;
      }

      this.state.selectedId = null;
      this.state.focusLayer = null;
      this.markDirty();
    };

    this.handleSvgMove = (event) => {
      const node = event.target.closest("[data-node-id]");
      const nextHovered = node ? node.dataset.nodeId : null;

      if (nextHovered === this.state.hoveredId) return;

      this.state.hoveredId = nextHovered;
      if (nextHovered && this.model.nodeById[nextHovered]) {
        this.state.hoverDomain = this.model.nodeById[nextHovered].domain;
      } else {
        this.state.hoverDomain = null;
      }

      this.markDirty();
    };

    this.handleSvgLeave = () => {
      if (!this.state.hoveredId && !this.state.hoverDomain) return;
      this.state.hoveredId = null;
      this.state.hoverDomain = null;
      this.markDirty();
    };

    this.handleDetailClick = (event) => {
      const chip = event.target.closest("[data-select-id]");
      if (!chip) return;

      const targetId = chip.dataset.selectId;
      if (!targetId || !this.model.packageById[targetId]) {
        return;
      }

      this.state.selectedId = targetId;
      this.state.focusLayer = null;
      this.markDirty();
    };

    this.controlsEl.addEventListener("click", this.handleControlsClick);
    this.svgEl.addEventListener("click", this.handleSvgClick);
    this.svgEl.addEventListener("mousemove", this.handleSvgMove);
    this.svgEl.addEventListener("mouseleave", this.handleSvgLeave);
    this.detailEl.addEventListener("click", this.handleDetailClick);
  },

  unbindEvents() {
    if (this.controlsEl && this.handleControlsClick) {
      this.controlsEl.removeEventListener("click", this.handleControlsClick);
    }
    if (this.svgEl && this.handleSvgClick) {
      this.svgEl.removeEventListener("click", this.handleSvgClick);
    }
    if (this.svgEl && this.handleSvgMove) {
      this.svgEl.removeEventListener("mousemove", this.handleSvgMove);
    }
    if (this.svgEl && this.handleSvgLeave) {
      this.svgEl.removeEventListener("mouseleave", this.handleSvgLeave);
    }
    if (this.detailEl && this.handleDetailClick) {
      this.detailEl.removeEventListener("click", this.handleDetailClick);
    }
  },

  syncFromDataset() {
    const data = normalizePayload(this.el.dataset.orbitPayload);
    this.data = data;
    this.model = computeModel(data);
    this.domainColorById = Object.create(null);
    this.model.domains.forEach((domain, index) => {
      this.domainColorById[domain.id] = domainColor(domain.id, index);
    });

    if (!this.model.packageById[this.state.selectedId]) {
      this.state.selectedId = null;
    }
    if (!this.model.packageById[this.state.hoveredId]) {
      this.state.hoveredId = null;
      this.state.hoverDomain = null;
    }

    this.markDirty();
  },

  markDirty() {
    this.state.dirty = true;
  },

  startAnimation() {
    const tick = (ts) => {
      let shouldRenderFrame = false;

      if (!this.state.paused) {
        if (this.lastTs === null) {
          this.lastTs = ts;
        }
        this.state.timeMs += ts - this.lastTs;
        this.lastTs = ts;
        shouldRenderFrame = true;
      } else {
        this.lastTs = ts;
      }

      if (this.state.dirty) {
        this.renderControls();
        this.renderLegend();
        this.renderDetailPanel();
        shouldRenderFrame = true;
        this.state.dirty = false;
      }

      if (shouldRenderFrame) {
        this.renderSvgFrame();
      }

      this.raf = requestAnimationFrame(tick);
    };

    this.raf = requestAnimationFrame(tick);
  },

  positionForNode(node) {
    const cfg = RING_CONFIG[node.layer] || RING_CONFIG.app;
    const angle = node.baseAngle + this.state.timeMs * cfg.speed * cfg.dir;
    return {
      x: CENTER_X + Math.cos(angle) * node.ring,
      y: CENTER_Y + Math.sin(angle) * node.ring,
    };
  },

  connectedSet(id) {
    const set = new Set();
    const deps = this.model.depsById[id] || [];
    deps.forEach((dep) => set.add(dep));

    Object.entries(this.model.depsById).forEach(([candidateId, candidateDeps]) => {
      if (candidateDeps.includes(id)) {
        set.add(candidateId);
      }
    });

    return set;
  },

  isNodeHighlighted(node, connectedIds) {
    if (this.state.selectedId && this.state.selectedId === this.model.centerId) {
      return true;
    }

    if (this.state.selectedId) {
      return this.state.selectedId === node.id || connectedIds.has(node.id);
    }

    if (this.state.focusLayer && node.layer !== this.state.focusLayer) {
      return false;
    }

    if (this.state.hoverDomain) {
      return node.domain === this.state.hoverDomain;
    }

    return true;
  },

  renderSvgFrame() {
    if (!this.svgEl) return;

    const connectedIds =
      this.state.selectedId && this.state.selectedId !== this.model.centerId
        ? this.connectedSet(this.state.selectedId)
        : new Set();

    const positions = Object.create(null);
    this.model.nodes.forEach((node) => {
      positions[node.id] = this.positionForNode(node);
    });

    const starsMarkup = this.stars
      .map((star, index) => {
        return `<circle key="star-${index}" cx="${star.cx.toFixed(2)}" cy="${star.cy.toFixed(2)}" r="${star.r.toFixed(2)}" fill="#ffffff" opacity="${star.o.toFixed(2)}"></circle>`;
      })
      .join("");

    const ringMarkup = Object.entries(RINGS)
      .map(([layer, radius]) => {
        const isFocused = this.state.focusLayer === layer;
        const dimmed = this.state.focusLayer && !isFocused;
        const opacity = isFocused ? 0.5 : dimmed ? 0.05 : 0.18;
        const stroke = LAYER_COLORS[layer] || "#888";

        return `
          <g data-ring-layer="${layer}" class="ecosystem-orbit-ring">
            <circle cx="${CENTER_X}" cy="${CENTER_Y}" r="${radius}" fill="none" stroke="transparent" stroke-width="24"></circle>
            <circle cx="${CENTER_X}" cy="${CENTER_Y}" r="${radius}" fill="none" stroke="${stroke}" stroke-width="${isFocused ? 1.5 : 0.7}" opacity="${opacity}" stroke-dasharray="3 8"></circle>
            <text x="${CENTER_X + radius + 14}" y="${CENTER_Y + 4}" fill="${stroke}" font-size="11" opacity="${isFocused ? 0.8 : dimmed ? 0.06 : 0.3}" font-family="monospace" letter-spacing="2">${layer.toUpperCase()}</text>
          </g>
        `;
      })
      .join("");

    const dependencyMarkup = this.renderDependencyLines(positions);

    const centerPkg = this.model.centerPackage;
    const sunId = this.model.centerId;
    const sunLabel = centerPkg ? escapeHtml(centerPkg.label || centerPkg.name) : "jido";

    const sunOpacity = this.state.selectedId === sunId ? 1 : 0.92;
    const sunDataAttr = sunId ? `data-sun-id="${escapeHtml(String(sunId))}"` : "";
    const sunMarkup = `
      <g ${sunDataAttr} class="ecosystem-orbit-sun">
        <circle cx="${CENTER_X}" cy="${CENTER_Y}" r="80" fill="url(#orbitSunGlow)"></circle>
        <circle cx="${CENTER_X}" cy="${CENTER_Y}" r="32" fill="url(#orbitSunCore)" opacity="${sunOpacity}"></circle>
        <circle cx="${CENTER_X}" cy="${CENTER_Y}" r="20" fill="#ffffff" opacity="0.1"></circle>
        <text x="${CENTER_X}" y="${CENTER_Y + 1.5}" text-anchor="middle" dominant-baseline="middle" fill="#060610" font-size="13" font-weight="800" font-family="monospace">${sunLabel}</text>
        <text x="${CENTER_X}" y="${CENTER_Y + 50}" text-anchor="middle" fill="${LAYER_COLORS.core}" font-size="8" opacity="0.4" font-family="monospace" letter-spacing="3">CORE</text>
      </g>
    `;

    const nodesMarkup = this.model.nodes
      .map((node) => {
        const pos = positions[node.id];
        const highlighted = this.isNodeHighlighted(node, connectedIds);
        const isSelected = this.state.selectedId === node.id;
        const isHovered = this.state.hoveredId === node.id;
        const layerColor = LAYER_COLORS[node.layer] || "#888";
        const nodeColor = this.domainColorById[node.domain] || "#9aa";
        const radius = isSelected ? node.radius + 4 : isHovered ? node.radius + 2 : node.radius;
        const opacity = highlighted ? 0.92 : 0.1;
        const textOpacity = highlighted ? 0.9 : 0.1;
        const strokeWidth = isSelected ? 2.5 : node.maturity === "experimental" ? 0.9 : 1.4;
        const dash = node.maturity === "experimental" ? "2 2" : "none";

        return `
          <g data-node-id="${escapeHtml(node.id)}" class="ecosystem-orbit-node">
            ${
              isSelected || isHovered || (highlighted && !this.state.selectedId)
                ? `<circle cx="${pos.x}" cy="${pos.y}" r="${radius + 10}" fill="${nodeColor}" opacity="${
                    isSelected ? 0.18 : isHovered ? 0.10 : 0.04
                  }"></circle>`
                : ""
            }
            <circle cx="${pos.x}" cy="${pos.y}" r="${radius}" fill="${highlighted ? layerColor : "#1a1a2a"}" stroke="${highlighted ? nodeColor : "#222"}" stroke-width="${strokeWidth}" stroke-dasharray="${dash}" opacity="${opacity}" filter="${
              isSelected ? "url(#orbitGlow)" : highlighted ? "url(#orbitSoftGlow)" : "none"
            }"></circle>
            <text x="${pos.x}" y="${pos.y - radius - 7}" text-anchor="middle" fill="${highlighted ? "#ddd" : "#333"}" font-size="11" font-family="monospace" font-weight="${
              isSelected ? 700 : 400
            }" opacity="${textOpacity}">${escapeHtml(node.label)}</text>
          </g>
        `;
      })
      .join("");

    this.svgEl.innerHTML = `
      <defs>
        <radialGradient id="orbitSunGlow" cx="50%" cy="50%" r="50%">
          <stop offset="0%" stop-color="#4EEEB4" stop-opacity="0.4"></stop>
          <stop offset="40%" stop-color="#4EEEB4" stop-opacity="0.08"></stop>
          <stop offset="100%" stop-color="#4EEEB4" stop-opacity="0"></stop>
        </radialGradient>
        <radialGradient id="orbitSunCore" cx="40%" cy="40%" r="55%">
          <stop offset="0%" stop-color="#ffffff" stop-opacity="0.95"></stop>
          <stop offset="40%" stop-color="#4EEEB4" stop-opacity="0.85"></stop>
          <stop offset="100%" stop-color="#1a7a5a" stop-opacity="0.7"></stop>
        </radialGradient>
        <filter id="orbitGlow"><feGaussianBlur stdDeviation="4" result="b"></feGaussianBlur><feMerge><feMergeNode in="b"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter>
        <filter id="orbitSoftGlow"><feGaussianBlur stdDeviation="2.5" result="b"></feGaussianBlur><feMerge><feMergeNode in="b"></feMergeNode><feMergeNode in="SourceGraphic"></feMergeNode></feMerge></filter>
      </defs>
      ${starsMarkup}
      ${ringMarkup}
      ${dependencyMarkup}
      ${sunMarkup}
      ${nodesMarkup}
    `;
  },

  renderDependencyLines(positions) {
    const selectedId = this.state.selectedId;
    if (!selectedId) {
      return "";
    }

    const sunId = this.model.centerId;
    const selectedIsSun = selectedId === sunId;
    const lines = [];

    const sourcePos = selectedIsSun
      ? { x: CENTER_X, y: CENTER_Y }
      : positions[selectedId] || { x: CENTER_X, y: CENTER_Y };

    if (selectedIsSun) {
      this.model.nodes.forEach((node) => {
        const pos = positions[node.id];
        if (!pos) return;
        lines.push({
          x1: CENTER_X,
          y1: CENTER_Y,
          x2: pos.x,
          y2: pos.y,
          color: LAYER_COLORS[node.layer] || "#999",
          dashed: false,
        });
      });
    } else {
      lines.push({
        x1: sourcePos.x,
        y1: sourcePos.y,
        x2: CENTER_X,
        y2: CENTER_Y,
        color: LAYER_COLORS.core,
        dashed: false,
      });

      (this.model.depsById[selectedId] || []).forEach((depId) => {
        const pos = positions[depId] || (depId === sunId ? { x: CENTER_X, y: CENTER_Y } : null);
        if (!pos) return;
        const depPkg = this.model.packageById[depId];
        const depLayer = depPkg ? depPkg.layer : "app";

        lines.push({
          x1: sourcePos.x,
          y1: sourcePos.y,
          x2: pos.x,
          y2: pos.y,
          color: LAYER_COLORS[depLayer] || "#999",
          dashed: false,
        });
      });

      Object.entries(this.model.depsById).forEach(([pkgId, deps]) => {
        if (!deps.includes(selectedId)) return;

        const pos = positions[pkgId];
        if (!pos) return;
        const pkg = this.model.packageById[pkgId];
        const layer = pkg ? pkg.layer : "app";

        lines.push({
          x1: pos.x,
          y1: pos.y,
          x2: sourcePos.x,
          y2: sourcePos.y,
          color: LAYER_COLORS[layer] || "#999",
          dashed: true,
        });
      });
    }

    return lines
      .map((line, index) => {
        return `<line key="dep-${index}" x1="${line.x1}" y1="${line.y1}" x2="${line.x2}" y2="${line.y2}" stroke="${line.color}" stroke-width="1.4" stroke-dasharray="${
          line.dashed ? "4 3" : "none"
        }" opacity="0.32"></line>`;
      })
      .join("");
  },

  renderControls() {
    if (!this.controlsEl) return;

    const sunSelected = this.state.selectedId && this.state.selectedId === this.model.centerId;

    const buttons = LAYER_BUTTONS.map((button) => {
      const isActive =
        button === "all"
          ? !this.state.focusLayer && !sunSelected
          : button === "core"
          ? sunSelected
          : this.state.focusLayer === button;

      const color = LAYER_COLORS[button] || "#888";
      const className = isActive
        ? "ecosystem-orbit-control ecosystem-orbit-control-active"
        : "ecosystem-orbit-control";

      return `<button type="button" data-orbit-control="${button}" class="${className}" style="${
        isActive && button !== "all" ? `--orbit-control-color: ${color};` : ""
      }">${button.toUpperCase()}</button>`;
    }).join("");

    const pauseLabel = this.state.paused ? "RESUME" : "PAUSE";

    this.controlsEl.innerHTML = `
      <div class="ecosystem-orbit-control-group">${buttons}</div>
      <button type="button" data-orbit-control="pause" class="ecosystem-orbit-control ecosystem-orbit-control-secondary">${pauseLabel}</button>
    `;
  },

  renderLegend() {
    if (!this.legendEl) return;

    const layerLegend = Object.entries(LAYER_COLORS)
      .map(([layer, color]) => {
        return `
          <div class="ecosystem-orbit-legend-item">
            <span class="ecosystem-orbit-legend-swatch" style="background:${color}"></span>
            <span class="ecosystem-orbit-legend-label">${escapeHtml(layer.toUpperCase())}</span>
          </div>
        `;
      })
      .join("");

    const domainsLegend = this.model.domains
      .map((domain, index) => {
        const count = this.model.nodes.filter((node) => node.domain === domain.id).length;
        const color = this.domainColorById[domain.id] || domainColor(domain.id, index);
        return `
          <div class="ecosystem-orbit-legend-domain">
            <span class="ecosystem-orbit-legend-dot" style="background:${color}"></span>
            <span class="ecosystem-orbit-legend-domain-label">${escapeHtml(domain.label)}</span>
            <span class="ecosystem-orbit-legend-domain-count">${count}</span>
          </div>
        `;
      })
      .join("");

    this.legendEl.innerHTML = `
      <div class="ecosystem-orbit-legend-row">${layerLegend}</div>
      <div class="ecosystem-orbit-domain-row">${domainsLegend}</div>
    `;
  },

  renderDetailPanel() {
    if (!this.detailEl) return;

    const selectedId = this.state.selectedId || this.state.hoveredId;
    const selectedPkg = selectedId ? this.model.packageById[selectedId] : null;

    if (!selectedPkg) {
      this.detailEl.innerHTML = `
        <div class="ecosystem-orbit-detail-empty">
          <div class="ecosystem-orbit-detail-title">Click a package to inspect dependencies</div>
          <div class="ecosystem-orbit-detail-copy">Desktop orbit is interactive. Mobile keeps the existing list layout.</div>
        </div>
      `;
      return;
    }

    if (selectedId === this.model.centerId) {
      this.detailEl.innerHTML = `
        <div class="ecosystem-orbit-detail-card">
          <div class="ecosystem-orbit-detail-heading">${escapeHtml(selectedPkg.title || selectedPkg.name)}</div>
          <div class="ecosystem-orbit-detail-meta">CORE · ${escapeHtml(toTitleCase(selectedPkg.maturity || "experimental"))}</div>
          <div class="ecosystem-orbit-detail-copy">Core runtime package at the center of the public ecosystem graph.</div>
          <a class="ecosystem-orbit-detail-link" href="${escapeHtml(selectedPkg.path)}">Open package page</a>
        </div>
      `;
      return;
    }

    const deps = this.model.depsById[selectedPkg.id] || [];
    const dependents = Object.entries(this.model.depsById)
      .filter(([_pkgId, pkgDeps]) => pkgDeps.includes(selectedPkg.id))
      .map(([pkgId]) => pkgId);

    const depChips = deps.length
      ? deps
          .map((depId) => {
            const depPkg = this.model.packageById[depId];
            const depLabel = depPkg ? depPkg.label : depId;
            return `<button type="button" data-select-id="${escapeHtml(depId)}" class="ecosystem-orbit-chip">${escapeHtml(depLabel)}</button>`;
          })
          .join("")
      : `<span class="ecosystem-orbit-chip ecosystem-orbit-chip-muted">none</span>`;

    const usedBy = dependents.length
      ? dependents
          .slice(0, 8)
          .map((depId) => {
            const pkg = this.model.packageById[depId];
            const label = pkg ? pkg.label : depId;
            return `<button type="button" data-select-id="${escapeHtml(depId)}" class="ecosystem-orbit-chip ecosystem-orbit-chip-secondary">${escapeHtml(label)}</button>`;
          })
          .join("")
      : `<span class="ecosystem-orbit-chip ecosystem-orbit-chip-muted">none</span>`;

    this.detailEl.innerHTML = `
      <div class="ecosystem-orbit-detail-card">
        <div class="ecosystem-orbit-detail-heading">${escapeHtml(selectedPkg.title || selectedPkg.name)}</div>
        <div class="ecosystem-orbit-detail-meta">
          ${escapeHtml(selectedPkg.layer.toUpperCase())} · ${escapeHtml(toTitleCase(selectedPkg.domain))} · ${escapeHtml(
      toTitleCase(selectedPkg.maturity || "experimental")
    )}
        </div>
        <div class="ecosystem-orbit-detail-group">
          <div class="ecosystem-orbit-detail-label">Depends On</div>
          <div class="ecosystem-orbit-chip-row">${depChips}</div>
        </div>
        <div class="ecosystem-orbit-detail-group">
          <div class="ecosystem-orbit-detail-label">Used By</div>
          <div class="ecosystem-orbit-chip-row">${usedBy}</div>
        </div>
        <a class="ecosystem-orbit-detail-link" href="${escapeHtml(selectedPkg.path)}">Open package page</a>
      </div>
    `;
  },
};

export default EcosystemOrbit;
