import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
    static targets = ["linkPreview"]

    connect() {
        const url = this.element.dataset.url; // Получаем URL из data-атрибута
        const name = this.element.dataset.name; // Получаем имя из data-атрибута

        this.renderBasicLink(url, name); // Всегда отображаем URL и имя

        // Затем пытаемся получить данные превью
        this.fetchLinkPreview(url);
    }

    async fetchLinkPreview(url) {
        try {
            const response = await fetch(`https://api.microlink.io/?url=${encodeURIComponent(url)}`);
            const data = await response.json();

            if (response.ok && data.status === "success" && data.data) {
                this.renderPreview(data.data);
            } else {
                this.renderError();
            }
        } catch (error) {
            console.error("Error fetching Microlink preview:", error);
            this.renderError();
        }
    }

    renderBasicLink(url, name) {
        // Отображаем URL и имя из формы, как они были введены
        if (this.hasLinkPreviewTarget) {
            this.linkPreviewTarget.innerHTML = `
        <p><strong>Name:</strong> ${name || 'No name provided'}</p>
        <p><strong>URL:</strong> <a href="${url}" target="_blank">${url}</a></p>
      `;
        }
    }

    renderPreview(data) {
        // Если данные успешно получены, добавляем превью
        if (this.hasLinkPreviewTarget) {
            this.linkPreviewTarget.innerHTML = `
        <div class="microlink_card">
          <img src="${data.image?.url || ''}" alt="${data.title || 'No title'}" />
          <h3>${data.title || 'No title available'}</h3>
          <p>${data.description || 'No description available'}</p>
          <a href="${data.url}" target="_blank">Read more</a>
        </div>
      `;
        }
    }

    renderError() {
        if (this.hasLinkPreviewTarget) {
            this.linkPreviewTarget.innerHTML += "<p>Failed to load preview</p>";
        }
    }
}
