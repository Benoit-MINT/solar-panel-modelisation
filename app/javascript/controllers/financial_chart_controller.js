import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="financial-chart"
export default class extends Controller {
  static targets = ["priceConsumption", "saleElectricity", "selfElectricity"]

  connect() {
    const labels = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre']
    var price_consumption_data = this.priceConsumptionTarget.dataset.value
    var price_consumption_data_json = JSON.parse(price_consumption_data)

    var sale_electricity_data = this.saleElectricityTarget.dataset.value
    var sale_electricity_data_json = JSON.parse(sale_electricity_data)

    var self_electricity_data = this.selfElectricityTarget.dataset.value
    var self_electricity_data_json = JSON.parse(self_electricity_data)

    var final_price_data_json = [];
    for (let i = 0; i < labels.length; i++) {
      final_price_data_json.push(price_consumption_data_json[i] - sale_electricity_data_json[i] - self_electricity_data_json[i]);
    }

    var self_electricity_array = [];
    for (let i = 0; i < labels.length; i++) {
      self_electricity_array.push([final_price_data_json[i], (final_price_data_json[i] + self_electricity_data_json[i])]);
    }

    var sale_electricity_array = [];
    for (let i = 0; i < labels.length; i++) {
      if (self_electricity_array[i][1] > 0) {
        sale_electricity_array.push(sale_electricity_data_json[i])
      } else {
        sale_electricity_array.push([self_electricity_array[i][1], (self_electricity_array[i][1] + sale_electricity_data_json[i])]);
      }
    }

    const data_test = {
      labels: labels,
      datasets: [{
          label: 'Prix initial',
          backgroundColor: 'rgba(54, 162, 235, 1)',
          stack: 'Stack 0',
          data: price_consumption_data_json
      }, {
          label: 'Autoconsommation',
          backgroundColor: 'rgba(255, 159, 64, 1)',
          stack: 'Stack 1',
          data: self_electricity_array
      }, {
          label: 'Revente',
          backgroundColor: 'rgba(255, 205, 86, 1)',
          stack: 'Stack 1',
          data: sale_electricity_array
      }, {
        label: 'Prix final',
        backgroundColor: 'rgba(75, 192, 192, 1)',
        stack: 'Stack 2',
        data: final_price_data_json
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
