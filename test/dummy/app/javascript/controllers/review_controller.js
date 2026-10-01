import { Controller } from "@hotwired/stimulus"

const PALETTE = ["#473191", "#0f6e56", "#9b1c3c", "#b45309", "#1d4e89", "#6d28d9", "#0e7490", "#9a3412"]

export default class extends Controller {
  static targets = ["toggle", "nameDialog", "author", "add", "popover", "quote", "thread", "body", "status"]
  static values = { url: String, path: String }

  connect() {
    this.reviews = []
    this.pending = null
    this.openId = null
    this.onSelection = this.onSelection.bind(this)
    document.addEventListener("pointerup", this.onSelection)
    if (this.element.parentElement !== document.body) document.body.append(this.element)
    if (readStorage("hdi-review-open") === "1") this.open()
  }

  disconnect() {
    document.removeEventListener("pointerup", this.onSelection)
    clearInterval(this.pollTimer)
  }

  toggle() {
    if (this.element.classList.contains("is-open")) this.close()
    else this.open()
  }

  open() {
    this.element.classList.add("is-open")
    document.querySelector(".hdi-page")?.classList.add("is-reviewing")
    writeStorage("hdi-review-open", "1")
    this.toggleTarget.setAttribute("aria-pressed", "true")
    this.toggleTarget.textContent = "Exit review"
    const saved = this.authorName()
    if (this.hasAuthorTarget) this.authorTarget.value = saved
    if (saved) {
      this.nameDialogTarget.hidden = true
      this.statusTarget.hidden = false
    } else {
      this.statusTarget.hidden = true
      this.nameDialogTarget.hidden = false
      this.authorTarget.focus()
    }
    this.refresh()
    clearInterval(this.pollTimer)
    this.pollTimer = setInterval(() => this.refresh(), 8000)
  }

  close() {
    this.element.classList.remove("is-open")
    document.querySelector(".hdi-page")?.classList.remove("is-reviewing")
    writeStorage("hdi-review-open", "")
    this.toggleTarget.setAttribute("aria-pressed", "false")
    this.toggleTarget.textContent = "Review"
    this.nameDialogTarget.hidden = true
    this.statusTarget.hidden = true
    this.hideAdd()
    this.hidePopover()
    clearInterval(this.pollTimer)
    this.layer()?.replaceChildren()
  }

  saveName(event) {
    event.preventDefault()
    const name = this.authorTarget.value.trim()
    if (!name) return
    writeStorage("hdi-review-author", name)
    this.nameDialogTarget.hidden = true
    this.statusTarget.hidden = false
  }

  authorName() {
    return readStorage("hdi-review-author").trim()
  }

  onSelection(event) {
    if (!this.element.classList.contains("is-open") || !this.authorName()) return
    if (this.addTarget.contains(event.target) || this.popoverTarget.contains(event.target)) return

    const selection = window.getSelection()
    const page = document.querySelector(".hdi-page")
    if (!selection || selection.isCollapsed || !selection.rangeCount || !page) {
      this.hideAdd()
      return
    }

    const range = selection.getRangeAt(0)
    if (!page.contains(range.commonAncestorContainer)) {
      this.hideAdd()
      return
    }

    const quote = selection.toString().replace(/\s+/g, " ").trim()
    if (quote.length < 2) return

    const rect = range.getBoundingClientRect()
    const pageRect = page.getBoundingClientRect()
    this.pending = {
      quote: quote.slice(0, 500),
      prefix: textBefore(range).slice(-24),
      x: clamp((rect.left - pageRect.left) / pageRect.width),
      y: clamp((rect.bottom - pageRect.top) / pageRect.height)
    }
    this.addTarget.hidden = false
    this.addTarget.style.left = `${Math.min(rect.right + 8, window.innerWidth - 40)}px`
    this.addTarget.style.top = `${Math.max(rect.top - 10, 8)}px`
  }

  startComment(event) {
    event.preventDefault()
    event.stopPropagation()
    if (!this.pending) return
    this.openId = null
    this.quoteTarget.textContent = this.pending.quote
    this.threadTarget.replaceChildren()
    this.bodyTarget.value = ""
    this.showPopover(this.addTarget.getBoundingClientRect())
    this.hideAdd()
  }

  hideAdd() {
    if (this.hasAddTarget) this.addTarget.hidden = true
  }

  hidePopover() {
    this.popoverTarget.hidden = true
    this.openId = null
  }

  async refresh() {
    const response = await fetch(`${this.urlValue}?path=${encodeURIComponent(this.pathValue)}`, {
      headers: { Accept: "application/json" }
    })
    if (!response.ok) return
    this.reviews = await response.json()
    this.paint()
    if (this.openId) this.fillThread(this.reviews.find((review) => review.id === this.openId))
  }

  paint() {
    const page = document.querySelector(".hdi-page")
    const layer = this.layer()
    if (!page || !layer) return

    layer.replaceChildren()
    const placed = []
    this.reviews.forEach((review) => {
      const baseX = (Number(review.x) || 0.15) * page.offsetWidth
      const baseY = (Number(review.y) || 0.15) * page.offsetHeight
      const neighbours = placed.filter((spot) => Math.hypot(spot.x - baseX, spot.y - baseY) < 36)
      const slot = neighbours.length
      const angle = -Math.PI / 2 + slot * 0.8
      const radius = slot === 0 ? 0 : 26 + Math.floor((slot - 1) / 6) * 22
      const x = baseX + Math.cos(angle) * radius
      const y = baseY + Math.sin(angle) * radius
      placed.push({ x: baseX, y: baseY })

      const button = document.createElement("button")
      button.type = "button"
      button.className = "hdi-review__tag"
      button.textContent = initials(review.author)
      button.title = review.author
      button.style.left = `${x}px`
      button.style.top = `${y}px`
      button.style.background = colorFor(review.author)
      const replies = review.replies || []
      if (replies.length) {
        const count = document.createElement("span")
        count.className = "hdi-review__count"
        count.textContent = String(1 + replies.length)
        button.append(count)
      }
      button.addEventListener("pointerdown", (event) => this.beginDrag(event, review, button))
      layer.append(button)
    })
  }

  beginDrag(event, review, button) {
    event.preventDefault()
    event.stopPropagation()
    const startX = event.clientX
    const startY = event.clientY
    let moved = false
    const page = document.querySelector(".hdi-page")

    const move = (ev) => {
      if (Math.hypot(ev.clientX - startX, ev.clientY - startY) < 5) return
      moved = true
      const rect = page.getBoundingClientRect()
      review.x = clamp((ev.clientX - rect.left) / rect.width)
      review.y = clamp((ev.clientY - rect.top) / rect.height)
      button.style.left = `${review.x * page.offsetWidth}px`
      button.style.top = `${review.y * page.offsetHeight}px`
    }

    const up = async () => {
      window.removeEventListener("pointermove", move)
      window.removeEventListener("pointerup", up)
      if (!moved) {
        this.openThread(review, button.getBoundingClientRect())
        return
      }
      await fetch(`${this.urlValue}/${review.id}`, {
        method: "PATCH",
        headers: jsonHeaders(),
        body: JSON.stringify({ x: review.x, y: review.y })
      })
    }

    window.addEventListener("pointermove", move)
    window.addEventListener("pointerup", up)
  }

  openThread(review, rect) {
    this.openId = review.id
    this.pending = null
    this.quoteTarget.textContent = review.quote || ""
    this.fillThread(review)
    this.bodyTarget.value = ""
    this.showPopover(rect)
    this.hideAdd()
  }

  fillThread(review) {
    if (!review) return
    this.threadTarget.replaceChildren()
    const mine = this.authorName()
    const messages = [
      { id: review.id, author: review.author, body: review.body, root: true },
      ...(review.replies || []).map((reply) => ({ ...reply, root: false }))
    ]
    messages.forEach((message) => {
      const item = document.createElement("li")
      const who = document.createElement("strong")
      who.textContent = message.author
      who.style.color = colorFor(message.author)
      const text = document.createElement("span")
      text.textContent = message.body
      item.append(who, text)
      if (message.author === mine) {
        const button = document.createElement("button")
        button.type = "button"
        button.className = "hdi-review__delete"
        button.textContent = "Delete"
        button.addEventListener("click", () => this.removeMessage(review, message))
        item.append(button)
      }
      this.threadTarget.append(item)
    })
  }

  async removeMessage(review, message) {
    const author = this.authorName()
    if (!author) return
    const url = message.root
      ? `${this.urlValue}/${review.id}`
      : `${this.urlValue}/${review.id}/replies/${message.id}`
    const response = await fetch(url, {
      method: "DELETE",
      headers: jsonHeaders(),
      body: JSON.stringify({ author })
    })
    if (!response.ok) return
    if (message.root) this.hidePopover()
    await this.refresh()
  }

  async submit(event) {
    event.preventDefault()
    const body = this.bodyTarget.value.trim()
    const author = this.authorName()
    if (!body || !author) return

    if (this.openId) {
      await fetch(`${this.urlValue}/${this.openId}/reply`, {
        method: "POST",
        headers: jsonHeaders(),
        body: JSON.stringify({ reply: { body, author } })
      })
    } else if (this.pending) {
      await fetch(this.urlValue, {
        method: "POST",
        headers: jsonHeaders(),
        body: JSON.stringify({
          review: {
            path: this.pathValue,
            kind: "text",
            quote: this.pending.quote,
            prefix: this.pending.prefix,
            body,
            author,
            x: this.pending.x,
            y: this.pending.y
          }
        })
      })
      this.pending = null
      window.getSelection()?.removeAllRanges()
    } else {
      return
    }

    this.bodyTarget.value = ""
    await this.refresh()
  }

  dragPopover(event) {
    if (event.button !== 0) return
    event.preventDefault()
    const handle = event.currentTarget
    const popover = this.popoverTarget
    const startX = event.clientX
    const startY = event.clientY
    const origin = popover.getBoundingClientRect()

    const move = (ev) => {
      const maxLeft = Math.max(8, window.innerWidth - popover.offsetWidth - 8)
      const maxTop = Math.max(8, window.innerHeight - 48)
      const left = origin.left + ev.clientX - startX
      const top = origin.top + ev.clientY - startY
      popover.style.left = `${Math.min(Math.max(8, left), maxLeft)}px`
      popover.style.top = `${Math.min(Math.max(8, top), maxTop)}px`
    }
    const stop = () => {
      handle.removeEventListener("pointermove", move)
      handle.removeEventListener("pointerup", stop)
      handle.removeEventListener("pointercancel", stop)
    }

    handle.setPointerCapture(event.pointerId)
    handle.addEventListener("pointermove", move)
    handle.addEventListener("pointerup", stop)
    handle.addEventListener("pointercancel", stop)
  }

  showPopover(rect) {
    this.popoverTarget.hidden = false
    const width = 320
    let left = rect.left
    let top = rect.bottom + 10
    if (left + width > window.innerWidth - 12) left = window.innerWidth - width - 12
    this.popoverTarget.style.left = `${Math.max(12, left)}px`
    this.popoverTarget.style.top = `${Math.max(12, top)}px`
    this.bodyTarget.focus()
  }

  layer() {
    const page = document.querySelector(".hdi-page")
    if (!page) return null
    let layer = page.querySelector(".hdi-review__layer")
    if (!layer) {
      layer = document.createElement("div")
      layer.className = "hdi-review__layer"
      page.append(layer)
    }
    return layer
  }
}

function initials(name) {
  return name.trim().split(/\s+/).slice(0, 2).map((part) => part[0] || "").join("").toUpperCase() || "?"
}

function colorFor(name) {
  let hash = 0
  for (const char of name || "") hash = (hash * 31 + char.charCodeAt(0)) >>> 0
  return PALETTE[hash % PALETTE.length]
}

function clamp(value) {
  if (!Number.isFinite(value)) return 0.15
  return Math.min(0.98, Math.max(0.02, value))
}

function readStorage(key) {
  try {
    const store = key === "hdi-review-open" ? sessionStorage : localStorage
    return store.getItem(key) || ""
  } catch (_error) {
    return ""
  }
}

function writeStorage(key, value) {
  try {
    if (key === "hdi-review-open") {
      if (value) sessionStorage.setItem(key, value)
      else sessionStorage.removeItem(key)
      return
    }
    if (value) localStorage.setItem(key, value)
    else localStorage.removeItem(key)
  } catch (_error) {
    // Private browsing can block storage. Review still works for this page view.
  }
}

function jsonHeaders() {
  return {
    "Content-Type": "application/json",
    Accept: "application/json",
    "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content || ""
  }
}

function textBefore(range) {
  const probe = range.cloneRange()
  const page = document.querySelector(".hdi-page")
  if (!page) return ""
  probe.setStart(page, 0)
  probe.setEnd(range.startContainer, range.startOffset)
  return probe.toString().replace(/\s+/g, " ")
}
