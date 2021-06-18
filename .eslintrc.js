module.exports = {
  env: {
    browser: true,
    es6: true,
  },
  extends: [
    "eslint:recommended",
    "plugin:react/recommended",
    "plugin:@typescript-eslint/eslint-recommended",
    "plugin:@typescript-eslint/recommended",
    "plugin:prettier/recommended",
  ],
  globals: {
    Atomics: "readonly",
    SharedArrayBuffer: "readonly",
  },
  parser: "@typescript-eslint/parser",
  parserOptions: {
    ecmaFeatures: {
      jsx: true,
    },
    ecmaVersion: 11,
    sourceType: "module",
  },
  plugins: ["react", "@typescript-eslint", "prettier"],
  rules: {
    "react/prop-types": 0,
    "no-empty-function": 0,
    "@typescript-eslint/explicit-module-boundary-types": 0,
    "no-unexpected-multiline": 0,
    "@typescript-eslint/no-explicit-any": 0,
    "@typescript-eslint/no-extra-semi": 0,
    "prettier/prettier": "error",
  },
  settings: {
    react: {
      version: "detect",
    },
  },
}
