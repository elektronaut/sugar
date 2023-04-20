module.exports = {
  "env": {
    "browser": true,
    "commonjs": true,
    "es6": true
  },
  "extends": [
    "eslint:recommended",
    "plugin:react/recommended"
  ],
  "overrides": [
    {
      "files": ["**/*.+(ts|tsx)"],
      "parser": "@typescript-eslint/parser",
      "extends": [
        "plugin:@typescript-eslint/recommended",
        "plugin:@typescript-eslint/recommended-requiring-type-checking"
      ]
    }
  ],
  "parserOptions": {
    "ecmaVersion": 2018,
    "ecmaFeatures": {
      "experimentalObjectRestSpread": true,
      "jsx": true
    },
    "project": true,
    "sourceType": "module",
    "tsconfigRootDir": __dirname
  },
  "plugins": [
    "react", "react-hooks", "@typescript-eslint"
  ],
  "root": true,
  "rules": {
    "linebreak-style": [
      "error",
      "unix"
    ],
    "quotes": [
      "error",
      "double"
    ],
    "semi": [
      "error",
      "always"
    ],
  },
  "settings": {
    "react": {
      "version": "detect"
    }
  }
};
