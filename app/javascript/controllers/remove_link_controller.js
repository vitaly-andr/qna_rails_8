import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["destroyField"]

    remove(event) {
        event.preventDefault()

        const destroyField = this.destroyFieldTarget

        if (destroyField) {
            destroyField.value = "true"
            this.element.style.display = "none"
        } else {
            console.error('Destroy field not found')
        }
    }
}
