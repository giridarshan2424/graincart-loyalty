/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        brand: {
          dark: '#1a1d1a',
          darker: '#121412',
          light: '#2a2f2a',
          green: '#4ade80',
          greenDark: '#22c55e',
          text: '#f3f4f6',
          textMuted: '#9ca3af'
        }
      }
    },
  },
  plugins: [],
}
