import { Controller } from '@hotwired/stimulus'

// Cycles the homepage “What we do” service spine: click a step, swipe the
// panel, or auto-advance. Auto-advance respects prefers-reduced-motion.
export default class extends Controller {
  static targets = ['input', 'panel', 'stage', 'steps']
  static values = {
    interval: { type: Number, default: 5000 },
    index: { type: Number, default: 0 }
  }

  connect () {
    this.pointerStartX = null
    this.reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)')
    this.onReducedMotionChange = () => this.syncAutoplay()
    this.onVisibilityChange = () => this.syncAutoplay()
    this.reducedMotion.addEventListener('change', this.onReducedMotionChange)
    document.addEventListener('visibilitychange', this.onVisibilityChange)

    this.element.addEventListener('pointerenter', this.pauseAutoplay)
    this.element.addEventListener('pointerleave', this.resumeAutoplay)
    this.element.addEventListener('focusin', this.pauseAutoplay)
    this.element.addEventListener('focusout', this.resumeAutoplay)

    this.show(this.indexValue, { silent: true })
    this.syncAutoplay()
  }

  disconnect () {
    this.stopAutoplay()
    this.reducedMotion.removeEventListener('change', this.onReducedMotionChange)
    document.removeEventListener('visibilitychange', this.onVisibilityChange)
    this.element.removeEventListener('pointerenter', this.pauseAutoplay)
    this.element.removeEventListener('pointerleave', this.resumeAutoplay)
    this.element.removeEventListener('focusin', this.pauseAutoplay)
    this.element.removeEventListener('focusout', this.resumeAutoplay)
  }

  select (event) {
    const index = Number(event.target.value)
    if (Number.isNaN(index)) return

    this.show(index)
    this.restartAutoplay()
  }

  show (index, { silent = false } = {}) {
    const count = this.panelTargets.length
    if (count === 0) return

    const next = ((index % count) + count) % count
    this.indexValue = next

    this.inputTargets.forEach((input, i) => {
      input.checked = i === next
    })

    this.panelTargets.forEach((panel, i) => {
      const active = i === next
      panel.classList.toggle('is-active', active)
      panel.toggleAttribute('hidden', !active)
    })

    if (!silent && this.hasStepsTarget) {
      this.stepsTarget.setAttribute('aria-activedescendant', this.inputTargets[next]?.id || '')
    }
  }

  next () {
    this.show(this.indexValue + 1)
  }

  previous () {
    this.show(this.indexValue - 1)
  }

  pointerDown (event) {
    if (event.pointerType === 'mouse' && event.button !== 0) return
    this.pointerStartX = event.clientX
  }

  pointerUp (event) {
    if (this.pointerStartX == null) return

    const delta = event.clientX - this.pointerStartX
    this.pointerStartX = null

    if (Math.abs(delta) < 48) return

    if (delta < 0) this.next()
    else this.previous()

    this.restartAutoplay()
  }

  pointerCancel () {
    this.pointerStartX = null
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
    if (this.intervalValue <= 0) return false
    return this.panelTargets.length > 1
  }

  startAutoplay () {
    this.stopAutoplay()
    this.timer = window.setInterval(() => this.next(), this.intervalValue)
  }

  stopAutoplay () {
    if (this.timer) {
      window.clearInterval(this.timer)
      this.timer = null
    }
  }
}
