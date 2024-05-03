import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="energy-overview"
export default class extends Controller {
  static targets = ["overviewEnergy"]

  connect() {
    const energy_data = this.overviewEnergyTarget.dataset.value
    const energy_data_json = JSON.parse(energy_data)

    const labels = ['Production', 'Autoconsommation', 'Renvoi']

    const dataColors = ['rgba(255, 159, 64, 1)', 'rgba(255, 205, 86, 1)', 'rgba(75, 192, 192, 1)', 'rgba(54, 162, 235, 1)', 'rgba(153, 102, 255, 1)', 'rgba(201, 203, 207, 1)', 'rgba(255, 129, 64, 1)', 'rgba(94, 142, 205, 1)', 'rgba(95, 122, 162, 1)', 'rgba(255, 99, 132, 1)']

    const datasets = []
    for (let i = 0; i < energy_data_json[0].length; i++) {
      datasets.push({
          label: `${energy_data_json[4][i]}`,
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
