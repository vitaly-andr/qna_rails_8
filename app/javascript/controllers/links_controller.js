import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["links", "template", "removeButton", "destroyField"]

    addLink(event) {
        event.preventDefault()

        const uniqueId = new Date().getTime()
        const content = this.templateTarget.innerHTML.replace(/NEW_RECORD/g, uniqueId)

        // Вставляем новый элемент ссылки в список
        this.linksTarget.insertAdjacentHTML('beforeend', content)
    }
}
