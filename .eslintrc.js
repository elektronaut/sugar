module.exports = {
  env: {
    browser: true,
    es2021: true
  },
  extends: ["eslint:recommended", "plugin:react/recommended", "prettier"],
  overrides: [
    {
      files: ["**/*.+(ts|tsx)"],
      parser: "@typescript-eslint/parser",
      extends: [
        "plugin:@typescript-eslint/recommended",
        "plugin:@typescript-eslint/recommended-requiring-type-checking"
      ]
    }
  ],
  parserOptions: {
    ecmaVersion: "latest",
    project: true,
    sourceType: "module",
    tsconfigRootDir: __dirname
  },
  plugins: ["react", "react-hooks", "@typescript-eslint"],
  root: true,
  rules: {
    "linebreak-style": ["error", "unix"],
    quotes: ["error", "double", { avoidEscape: true }],
    semi: ["error", "always"]
  },
  settings: {
    react: {
      version: "detect"
    }
  }
};
