import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";

// Connects to data-controller="consumption-chart"
export default class extends Controller {
  static targets = ["consumptionHome"]

  connect() {
    const labels = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    var consumption_data = this.consumptionHomeTarget.dataset.value
    var consumption_data_json = JSON.parse(consumption_data)

    new Chart(this.element, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [{
          label: 'Consommation mensuelle (kW/h)',
          data: consumption_data_json,
          backgroundColor: [
            'rgb(232, 223, 202)',
          ],
          hoverOffset: 4
        }]
      }
    });
  }
}
