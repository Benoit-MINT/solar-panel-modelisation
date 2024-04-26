import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="address-autocomplete"
export default class extends Controller {
  static targets = ["address", "suggestions"]

  connect() {
  }

  search() {
    this.suggestionsTarget.innerHTML = '';
    var address = this.addressTarget.value.replace(/[, ]+/g, '+');
    if (address.length > 1) {
      var url = `https://nominatim.openstreetmap.org/search?q=${address}&format=json&countrycodes=fr`
      fetch(url)
      .then(response => response.json())
      .then((data) => {
        data.slice(0, 5).forEach((suggestion) => {
          this.suggestionsTarget.insertAdjacentHTML("beforeend", `<li data-action="click->address-autocomplete#select">${suggestion.display_name}</li>`);
        });
      });
    }
  }

  select(event) {
    console.log(event.target.innerText)
    console.log(this.addressTarget.value)
    this.addressTarget.value = event.target.innerText
    this.suggestionsTarget.innerHTML = '';
  }
}
