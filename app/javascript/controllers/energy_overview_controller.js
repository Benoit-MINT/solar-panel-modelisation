import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="energy-overview"
export default class extends Controller {
  static targets = ["overviewEnergy"]

  connect() {
    console.log(this.overviewEnergyTarget.dataset.value)

  }
}
