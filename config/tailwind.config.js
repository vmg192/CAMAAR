const defaultTheme = require('tailwindcss/defaultTheme')

module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      colors: {
        // Verificar se as cores estão corretas
        primary: '#1D4ED8',   // Azul institucional
        secondary: '#9333EA', // Roxo secundário
        danger: '#DC2626',    // Vermelho de erro
        success: '#16A34A',   // Verde de sucesso
        background: '#F3F4F6' // Cinza claro de fundo
      },
      fontFamily: {
        // Especificar a fonte
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}