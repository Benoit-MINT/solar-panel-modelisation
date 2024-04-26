import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static targets = ["address"]

  connect() {
  }

  search(event) {
    var result = []
    var address = this.addressTarget.value.replace(/[, ]+/g, '+');
    var url = `https://nominatim.openstreetmap.org/search?q=${address}&format=json&countrycodes=fr`
    console.log(url)
    fetch(url)
    .then(response => response.json())
    .then((data) => {
      console.log(data[0].display_name);
    });

  }
}
