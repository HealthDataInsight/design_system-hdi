import { Controller } from '@hotwired/stimulus'

// Start hero fade-in only after the background image is ready so a slow
// paint / hard refresh does not skip past the animation.
export default class extends Controller {
  static values = {
    var: { type: String, default: '--hdi-hero-image' }
  }

  connect () {
    this.reveal = this.reveal.bind(this)
    this.element.classList.remove('is-ready')

    const raw = getComputedStyle(this.element).getPropertyValue(this.varValue).trim()
    const match = raw.match(/url\(\s*["']?(.+?)["']?\s*\)/i)
    const src = match?.[1]

    if (!src) {
      this.reveal()
      return
    }

    const img = new Image()
    img.addEventListener('load', this.reveal, { once: true })
    img.addEventListener('error', this.reveal, { once: true })
    img.src = src
    if (img.complete) this.reveal()
  }

  reveal () {
    // Force a reflow so re-adding the class restarts the CSS animation.
    this.element.classList.remove('is-ready')
    void this.element.offsetWidth
    this.element.classList.add('is-ready')
  }
}
