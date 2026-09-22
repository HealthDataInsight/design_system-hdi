import { Controller } from '@hotwired/stimulus'

// Partner logo strip: gentle continuous scroll with prev/next controls.
// Autoplay pauses for prefers-reduced-motion, hover, focus, and hidden tabs.
export default class extends Controller {
  static targets = ['track']
  static values = {
    speed: { type: Number, default: 0.35 },
    step: { type: Number, default: 220 }
  }

  connect () {
    this.paused = false
    this.raf = null
    this.loopWidth = null
    this.reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)')
    this.onReducedMotionChange = () => this.syncAutoplay()
    this.onVisibilityChange = () => this.syncAutoplay()
    this.onResize = () => this.refresh()

    this.reducedMotion.addEventListener('change', this.onReducedMotionChange)
    document.addEventListener('visibilitychange', this.onVisibilityChange)
    window.addEventListener('resize', this.onResize)

    this.element.addEventListener('pointerenter', this.pauseAutoplay)
    this.element.addEventListener('pointerleave', this.resumeAutoplay)
    this.element.addEventListener('focusin', this.pauseAutoplay)
    this.element.addEventListener('focusout', this.resumeAutoplay)

    this.trackTarget?.querySelectorAll('img').forEach((img) => {
      if (!img.complete) {
        img.addEventListener('load', this.refresh, { once: true })
      }
    })

    this.refresh()
  }

  disconnect () {
    this.stopAutoplay()
    this.reducedMotion.removeEventListener('change', this.onReducedMotionChange)
    document.removeEventListener('visibilitychange', this.onVisibilityChange)
    window.removeEventListener('resize', this.onResize)
    this.element.removeEventListener('pointerenter', this.pauseAutoplay)
    this.element.removeEventListener('pointerleave', this.resumeAutoplay)
    this.element.removeEventListener('focusin', this.pauseAutoplay)
    this.element.removeEventListener('focusout', this.resumeAutoplay)
  }

  refresh = () => {
    this.prepareLoop()
    this.syncControls()
    this.syncAutoplay()
  }

  previous (event) {
    event?.preventDefault()
    this.nudge(-this.stepValue)
    this.restartAutoplay()
  }

  next (event) {
    event?.preventDefault()
    this.nudge(this.stepValue)
    this.restartAutoplay()
  }

  prepareLoop () {
    if (!this.hasTrackTarget) return

    const track = this.trackTarget
    track.querySelectorAll('[data-carousel-clone]').forEach((node) => node.remove())
    this.loopWidth = null

    if (track.scrollWidth <= track.clientWidth + 1) return

    this.loopWidth = track.scrollWidth

    Array.from(track.children).forEach((node) => {
      const clone = node.cloneNode(true)
      clone.setAttribute('data-carousel-clone', '')
      clone.setAttribute('aria-hidden', 'true')
      clone.querySelectorAll('a, button').forEach((el) => {
        el.setAttribute('tabindex', '-1')
      })
      track.appendChild(clone)
    })
  }

  nudge (delta) {
    if (!this.hasTrackTarget) return

    const track = this.trackTarget
    if (track.scrollWidth <= track.clientWidth + 1) return

    let next = track.scrollLeft + delta
    if (this.loopWidth) {
      if (next >= this.loopWidth) next -= this.loopWidth
      if (next < 0) next += this.loopWidth
    }
    track.scrollLeft = next
  }

  tick = () => {
    if (!this.canAutoplay()) {
      this.stopAutoplay()
      return
    }

    const track = this.trackTarget
    track.scrollLeft += this.speedValue
    if (this.loopWidth && track.scrollLeft >= this.loopWidth) {
      track.scrollLeft -= this.loopWidth
    }

    this.raf = window.requestAnimationFrame(this.tick)
  }

  syncControls () {
    const overflowing = this.hasTrackTarget &&
      (this.loopWidth != null || this.trackTarget.scrollWidth > this.trackTarget.clientWidth + 1)

    this.element.classList.toggle('hdi-carousel--scrollable', overflowing)
    this.element.querySelectorAll('.hdi-carousel__control').forEach((btn) => {
      btn.hidden = !overflowing
      btn.disabled = !overflowing
    })
  }

  syncAutoplay = () => {
    if (this.canAutoplay()) this.startAutoplay()
    else this.stopAutoplay()
  }

  pauseAutoplay = () => {
    this.paused = true
    this.stopAutoplay()
  }

  resumeAutoplay = () => {
    this.paused = false
    this.syncAutoplay()
  }

  restartAutoplay () {
    this.stopAutoplay()
    this.syncAutoplay()
  }

  canAutoplay () {
    if (this.paused) return false
    if (document.hidden) return false
    if (this.reducedMotion.matches) return false
    if (!this.hasTrackTarget) return false
    return this.loopWidth != null
  }

  startAutoplay () {
    this.stopAutoplay()
    this.raf = window.requestAnimationFrame(this.tick)
  }

  stopAutoplay () {
    if (this.raf) {
      window.cancelAnimationFrame(this.raf)
      this.raf = null
    }
  }
}
