import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "label", "filename", "mimeType"]

  syncFileMetadata() {
    const file = this.inputTarget.files[0]
    if (!file) return

    this.labelTarget.innerText = file.name
    this.filenameTarget.value = file.name
    this.mimeTypeTarget.value = file.type
  }
}
