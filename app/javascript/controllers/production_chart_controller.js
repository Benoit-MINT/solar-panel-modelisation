import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="production-chart"
export default class extends Controller {
  static targets = ["solarProduction", "selfConsumption", "backEnergy", "homeConsumption"]

  connect() {
    const labels = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    var home_consumption_data = this.homeConsumptionTarget.dataset.value
    var home_consumption_data_json = JSON.parse(home_consumption_data)

    var back_energy_data = this.backEnergyTarget.dataset.value
    var back_energy_data_json = JSON.parse(back_energy_data)

    var self_consumption_data = this.selfConsumptionTarget.dataset.value
    var self_consumption_data_json = JSON.parse(self_consumption_data)

    var consumption_network_data_json = [];
    for (let i = 0; i < home_consumption_data_json.length; i++) {
      consumption_network_data_json.push(home_consumption_data_json[i] - self_consumption_data_json[i]);
    }

    console.log(consumption_network_data_json)

    const data_test = {
      labels: labels,
      datasets: [{
          label: 'Autoconsommation',
          backgroundColor: 'green',
          stack: 'Stack 0',
          data: self_consumption_data_json
      }, {
          label: 'Consommation sur le réseau',
          backgroundColor: 'blue',
          stack: 'Stack 0',
          data: consumption_network_data_json
      }, {
          label: 'Production autoconsommée',
          backgroundColor: 'green',
          stack: 'Stack 1',
          data: self_consumption_data_json
      }, {
          label: 'Renvoi sur le réseau',
          backgroundColor: 'yellow',
          stack: 'Stack 1',
          data: back_energy_data_json
      }]
    };

    const config_test = {
      type: 'bar',
      data: data_test,
      options: {
        scales: {
          x: {
            stacked: true
          },
          y: {
            stacked: true
          }
        }
      }
    };

    new Chart(
      this.element,
      config_test
    );
  }
}
