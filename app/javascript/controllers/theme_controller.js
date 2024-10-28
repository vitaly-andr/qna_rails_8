import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="theme"
export default class extends Controller {
  static targets = ["darkIcon", "lightIcon"]

  connect() {
    console.log('Theme controller connected to button');
    this.toggleIcons()

    // Check the user's color theme preference on page load
    if (localStorage.getItem('color-theme') === 'dark' ||
        (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }

  toggle() {
    // Toggle icons inside the button
    this.darkIconTarget.classList.toggle('hidden')
    this.lightIconTarget.classList.toggle('hidden')

    // Update theme in localStorage
    if (localStorage.getItem('color-theme') === 'light') {
      document.documentElement.classList.add('dark')
      localStorage.setItem('color-theme', 'dark')
    } else {
      document.documentElement.classList.remove('dark')
      localStorage.setItem('color-theme', 'light')
    }
  }

  toggleIcons() {
    if (localStorage.getItem('color-theme') === 'dark' ||
        (!('color-theme' in localStorage) && window.matchMedia('(prefers-color-scheme: dark)').matches)) {
      this.lightIconTarget.classList.remove('hidden')
      this.darkIconTarget.classList.add('hidden')
    } else {
      this.darkIconTarget.classList.remove('hidden')
      this.lightIconTarget.classList.add('hidden')
    }
  }
}
