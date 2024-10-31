// /** @type {import('tailwindcss').Config} */
// module.exports = {
//   content: ["node_modules/preline/dist/*.js"],
//   theme: {
//     extend: {},
//   },
//   plugins: [require("@tailwindcss/forms"), require("preline/plugin")],
// };

module.exports = {
  // configure the paths to all of your source files
  content: [
    "node_modules/preline/dist/*.js",
    "./src/**/*.{html,js}",
    "lib/**/*.{ex,heex,html}",
  ],

  // enable dark mode via class strategy
  darkMode: "class",

  theme: {
    extend: {
      // extend base Tailwind CSS utility classes
    },
  },

  // add plugins to your Tailwind CSS project
  plugins: [require("@tailwindcss/forms"), require("preline/plugin")],
};
