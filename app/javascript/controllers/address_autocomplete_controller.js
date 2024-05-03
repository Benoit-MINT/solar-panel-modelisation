import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static targets = ["address", "latlon", "map", "addressList"]

  connect() {
    // on initialise une map
    this.map(48.866667, 2.333333, 4)
  }

  search() {
    this.addressListTarget.innerHTML = '';
    var addressSearch = this.addressTarget.value.replace(/[, ]+/g, '+');
    if (addressSearch.length > 4) {
      var url = `https://api-adresse.data.gouv.fr/search/?q=${addressSearch}&limit=5`
      fetch(url)
      .then(response => response.json())
      .then((data) => {
        data.features.forEach((suggestion) => {
          var label = suggestion.properties.label
          var lat = suggestion.geometry.coordinates[1]
          var lon = suggestion.geometry.coordinates[0]
          this.addressListTarget.insertAdjacentHTML("beforeend", `<li class="my-1" data-action="click->address-autocomplete#select" data-address-autocomplete-target="latlon" data-value = "[${lat}, ${lon}]">${label}</li>`);
        });
      });
      document.getElementById('addressModal').style.display = 'block';
    }
  }

  select(event) {
    this.addressTarget.value = event.target.innerText

    const latlon = this.latlonTarget.dataset.value
    const latlon_data = JSON.parse(latlon)
    this.map(latlon_data[0], latlon_data[1], 15)

    this.addressListTarget.innerHTML = ''
    document.getElementById('addressModal').style.display = 'none';
  }

  map(lat, lon, zoom) {
    this.mapTarget.innerHTML = '<div id="map"></div>';

    var map = L.map('map').setView([lat, lon], zoom);

    L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 20,
    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    }).addTo(map);

    var marker = L.marker([lat, lon]).addTo(map);
  }
}
