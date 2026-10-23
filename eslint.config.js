import js from "@eslint/js"
import stylistic from "@stylistic/eslint-plugin"
import globals from "globals"

export default [
  {
    ignores: ["vendor/**", "public/**", "node_modules/**", "app/assets/builds/**", "coverage/**"]
  },
  js.configs.recommended,
  {
    files: ["app/javascript/**/*.js", "spec/javascript/**/*.js", "*.config.js"],
    languageOptions: {
      ecmaVersion: "latest",
      sourceType: "module",
      globals: { ...globals.browser, twttr: "readonly" } // twttr comes from Twitter's widgets.js
    },
    plugins: { "@stylistic": stylistic },
    rules: {
      "@stylistic/semi": ["error", "never"],
      "@stylistic/quotes": ["error", "double", { allowTemplateLiterals: "always" }],
      "@stylistic/no-trailing-spaces": "error",
      "@stylistic/no-multiple-empty-lines": ["error", { max: 2 }],
      "no-unused-vars": ["error", { vars: "all", args: "none" }],
      "prefer-const": "error",
      curly: ["error", "multi-line"]
    }
  }
]
