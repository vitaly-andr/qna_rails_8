import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["output"]

    connect() {
        const url = this.element.dataset.url
        const gistId = this.extractGistId(url)
        if (gistId) {
            this.fetchGist(gistId)
        }
    }

    extractGistId(url) {
        const gistRegex = /gist\.github\.com\/.+\/([a-zA-Z0-9]+)/
        const match = url.match(gistRegex)
        return match ? match[1] : null
    }

    async fetchGist(gistId) {
        const apiUrl = `https://api.github.com/gists/${gistId}`
        try {
            const response = await fetch(apiUrl)
            const data = await response.json()
            const content = this.extractGistContent(data)
            this.outputTarget.innerHTML = `<pre>${content}</pre>`
        } catch (error) {
            this.outputTarget.innerHTML = "Failed to load Gist"
        }
    }

    extractGistContent(data) {
        return Object.values(data.files)
            .map(file => file.content)
            .join("\n")
    }
}