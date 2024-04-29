import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="energy-overview"
export default class extends Controller {
  static targets = ["overviewEnergy"]

  connect() {
    const energy_data = this.overviewEnergyTarget.dataset.value
    const energy_data_json = JSON.parse(energy_data)

    const labels = ['Production', 'Autoconsommation', 'Renvoi']

    const dataColors = ['green', 'blue', 'yellow', 'red', 'orange', 'purple', 'pink', 'cyan', 'magenta', 'lime']

    const datasets = []
    for (let i = 0; i < energy_data_json[0].length; i++) {
      datasets.push({
          label: `${energy_data_json[0][i]} kW/h`,
          backgroundColor: dataColors[i],
          stack: `Stack ${i}`,
          data: [energy_data_json[1][i], energy_data_json[2][i], energy_data_json[3][i]]
      });
    }

    const data = {
      labels: labels,
      datasets: datasets
    };

    const config = {
      type: 'bar',
      data: data,
      options: {
        scales: {
          x: {
            stacked: false
          },
          y: {
            stacked: false
          }
        }
      }
    };

    new Chart(
      this.element,
      config
    );
  }
}
