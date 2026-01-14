// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const colors = require("tailwindcss/colors");
const plugin = require("tailwindcss/plugin");
const fs = require("fs");
const path = require("path");

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/*_web.ex",
    "../lib/*_web/**/*.*ex",
    "../deps/petal_components/**/*.*ex",
  ],
  theme: {
    container: {
      center: true,
      padding: "1.5rem",
      screens: {
        "2xl": "1000px",
      },
    },
    extend: {
      colors: {
        primary: {
          DEFAULT: "hsl(var(--primary))",
          foreground: "hsl(var(--primary-foreground))",
          50: "hsl(var(--primary))",
          100: "hsl(var(--primary) / 0.9)",
          200: "hsl(var(--primary) / 0.8)",
          300: "hsl(var(--primary) / 0.7)",
          400: "hsl(var(--primary) / 0.6)",
          500: "hsl(var(--primary) / 0.5)",
          600: "hsl(var(--primary))",
          700: "hsl(var(--primary) / 0.85)",
          800: "hsl(var(--primary) / 0.75)",
          900: "hsl(var(--primary) / 0.65)",
          950: "hsl(var(--primary) / 0.5)",
        },
        secondary: {
          DEFAULT: "hsl(var(--secondary))",
          foreground: "hsl(var(--secondary-foreground))",
          50: "hsl(var(--secondary) / 0.5)",
          100: "hsl(var(--secondary) / 0.4)",
          200: "hsl(var(--secondary) / 0.35)",
          300: "hsl(var(--secondary) / 0.3)",
          400: "hsl(var(--secondary) / 0.25)",
          500: "hsl(var(--secondary) / 0.2)",
          600: "hsl(var(--secondary))",
          700: "hsl(var(--secondary) / 0.8)",
          800: "hsl(var(--secondary) / 0.7)",
          900: "hsl(var(--secondary) / 0.6)",
          950: "hsl(var(--secondary) / 0.5)",
        },
        success: colors.emerald,
        danger: colors.red,
        warning: colors.yellow,
        info: colors.gray,
        gray: colors.gray,
        border: "hsl(var(--border))",
        "border-strong": "hsl(var(--border-strong))",
        input: "hsl(var(--input))",
        ring: "hsl(var(--ring))",
        background: "hsl(var(--background))",
        foreground: "hsl(var(--foreground))",
        surface: "hsl(var(--surface))",
        elevated: "hsl(var(--elevated))",
        muted: {
          DEFAULT: "hsl(var(--muted))",
          foreground: "hsl(var(--muted-foreground))",
        },
        accent: {
          DEFAULT: "hsl(var(--accent))",
          foreground: "hsl(var(--accent-foreground))",
          green: "hsl(var(--accent-green))",
          yellow: "hsl(var(--accent-yellow))",
          cyan: "hsl(var(--accent-cyan))",
          red: "hsl(var(--accent-red))",
        },
        card: {
          DEFAULT: "hsl(var(--card))",
          foreground: "hsl(var(--card-foreground))",
        },
        destructive: {
          DEFAULT: "hsl(var(--destructive))",
          foreground: "hsl(var(--destructive-foreground))",
        },
        popover: {
          DEFAULT: "hsl(var(--popover))",
          foreground: "hsl(var(--popover-foreground))",
        },
        sidebar: {
          DEFAULT: "hsl(var(--sidebar-background))",
          foreground: "hsl(var(--sidebar-foreground))",
          primary: "hsl(var(--sidebar-primary))",
          "primary-foreground": "hsl(var(--sidebar-primary-foreground))",
          accent: "hsl(var(--sidebar-accent))",
          "accent-foreground": "hsl(var(--sidebar-accent-foreground))",
          border: "hsl(var(--sidebar-border))",
          ring: "hsl(var(--sidebar-ring))",
        },
        code: {
          bg: "hsl(var(--code-bg))",
          border: "hsl(var(--code-border))",
          keyword: "hsl(var(--code-keyword))",
          string: "hsl(var(--code-string))",
          comment: "hsl(var(--code-comment))",
          function: "hsl(var(--code-function))",
          type: "hsl(var(--code-type))",
        },
      },
      fontFamily: {
        mono: ["IBM Plex Mono", "JetBrains Mono", "Share Tech Mono", "monospace"],
        sans: ["Inter", "system-ui", "sans-serif"],
        display: ["VT323", "monospace"],
      },
      borderRadius: {
        lg: "var(--radius)",
        md: "calc(var(--radius) - 2px)",
        sm: "calc(var(--radius) - 4px)",
      },
      keyframes: {
        "fade-in": {
          from: { opacity: "0", transform: "translateY(10px)" },
          to: { opacity: "1", transform: "translateY(0)" },
        },
        "pulse-glow": {
          "0%, 100%": {
            opacity: "1",
            boxShadow:
              "0 0 5px theme(colors.success.400), 0 0 20px theme(colors.success.400)",
          },
          "50%": {
            opacity: ".7",
            boxShadow:
              "0 0 2px theme(colors.success.400), 0 0 10px theme(colors.success.400)",
          },
        },
      },
      animation: {
        "fade-in": "fade-in 0.5s ease-out forwards",
        "pulse-glow": "pulse-glow 2s cubic-bezier(0.4, 0, 0.6, 1) infinite",
      },
    },
  },
  darkMode: "class",
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/typography"),
    plugin(({ addVariant }) =>
      addVariant("phx-click-loading", [
        ".phx-click-loading&",
        ".phx-click-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-submit-loading", [
        ".phx-submit-loading&",
        ".phx-submit-loading &",
      ])
    ),
    plugin(({ addVariant }) =>
      addVariant("phx-change-loading", [
        ".phx-change-loading&",
        ".phx-change-loading &",
      ])
    ),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized");
      let values = {};
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"],
      ];
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach((file) => {
          let name = path.basename(file, ".svg") + suffix;
          values[name] = { name, fullPath: path.join(iconsDir, dir, file) };
        });
      });
      matchComponents(
        {
          hero: ({ name, fullPath }) => {
            let content = fs
              .readFileSync(fullPath)
              .toString()
              .replace(/\r?\n|\r/g, "");
            let size = theme("spacing.6");
            if (name.endsWith("-mini")) {
              size = theme("spacing.5");
            } else if (name.endsWith("-micro")) {
              size = theme("spacing.4");
            }
            return {
              [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
              "-webkit-mask": `var(--hero-${name})`,
              mask: `var(--hero-${name})`,
              "mask-repeat": "no-repeat",
              "background-color": "currentColor",
              "vertical-align": "middle",
              display: "inline-block",
              width: size,
              height: size,
            };
          },
        },
        { values }
      );
    }),
    plugin(function ({ addUtilities }) {
      addUtilities({
        ".neon-glow": {
          boxShadow:
            "0 0 5px theme(colors.success.400), 0 0 20px theme(colors.success.400)",
        },
        ".neon-border": {
          border: "1px solid theme(colors.success.400)",
          boxShadow: "0 0 5px theme(colors.success.400)",
        },
      });
    }),
  ],
};
