import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="map-home"
export default class extends Controller {
  static targets = ["lat", "long"]

  connect() {
    var lat = this.latTarget.dataset.value;
    var long = this.longTarget.dataset.value;
    var map = L.map('map').setView([lat, long], 15);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 20,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    var marker = L.marker([lat, long]).addTo(map);

  }
}
