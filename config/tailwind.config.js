const defaultTheme = require("tailwindcss/defaultTheme")

// Colours that change with the theme are CSS variables (set in application.tailwind.css), so the templates'
// existing classes switch between light and dark without a dark: variant on each one
const themed = (name) => `rgb(var(--${name}) / <alpha-value>)`
const scale = (name, steps) => Object.fromEntries(steps.map((step) => [step, themed(`${name}-${step}`)]))
const colors = require("tailwindcss/colors")

module.exports = {
  darkMode: "selector",
  content: [
    "./public/*.html",
    "./app/helpers/**/*.rb",
    "./app/javascript/**/*.js",
    "./app/views/**/*.{erb,haml,html,slim}"
  ],
  theme: {
    extend: {
      colors: {
        surface: themed("surface"),
        raised: themed("raised"),
        gray: scale("gray", [50, 100, 200, 300, 400, 500, 600, 700, 800, 900, 950]),
        orange: { ...colors.orange, ...scale("orange", [50, 100, 200, 700, 800, 900]) },
      },
      fontFamily: {
        naskh: ["Noto Naskh Arabic", "Arial", ...defaultTheme.fontFamily.sans],
        montserrat: ["Montserrat", ...defaultTheme.fontFamily.sans],
      },
    },
  },
  plugins: [
    require("@tailwindcss/forms"),
    require("@tailwindcss/aspect-ratio"),
    require("@tailwindcss/typography"),
    require("@tailwindcss/container-queries"),
    require("@tailwindcss/forms"),
  ]
}
