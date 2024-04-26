import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="production-chart"
export default class extends Controller {
  static targets = ["solarProduction"]

  connect() {
    const labels = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    var production_data = this.solarProductionTarget.dataset.value
    var production_data_json = JSON.parse(production_data)

    new Chart(this.element, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Production solaire mensuelle (kW/h)',
          data: production_data_json,
          backgroundColor: [
          'rgb(54, 162, 235)',
          ],
          hoverOffset: 4
        }]
      }
    });
  }
}
