import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static targets = ["address", "latlon", "map"]

  connect() {
    this.map(48.866667, 2.333333, 4)
  }

  search(event) {
    const datalist = document.getElementById("address_list")
    datalist.innerHTML = '';
    var address = this.addressTarget.value.replace(/[, ]+/g, '+');
    if (address.length > 2) {
      var url = `https://nominatim.openstreetmap.org/search?q=${address}&format=json&countrycodes=fr`
      fetch(url)
      .then(response => response.json())
      .then((data) => {
        data.slice(0, 3).forEach((suggestion) => {
          datalist.insertAdjacentHTML("beforeend", `<option value="${suggestion.display_name}" data-address-autocomplete-target="latlon" data-value = "[${suggestion.lat}, ${suggestion.lon}]">`);
          // console.log(suggestion.lat)
        });
      });
    }
  }

  select() {
    const latlon = this.latlonTarget.dataset.value
    const latlon_data = JSON.parse(latlon)
    this.map(latlon_data[0], latlon_data[1], 15)
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
