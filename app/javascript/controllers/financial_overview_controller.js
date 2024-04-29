import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";


// Connects to data-controller="financial-overview"
export default class extends Controller {
  static targets = ["overviewFinancial", "investmentGraph", "roiGraph", "profitGraph", "performanceGraph"]

  connect() {
    const financial_data = this.overviewFinancialTarget.dataset.value
    const financial_data_json = JSON.parse(financial_data)

    const titles = ['Investissement (€)', 'ROI (années)', 'Bénéfices (€, à 45 ans)', 'Rendement (%, à 45 ans)']

    console.log(financial_data_json)

    const labels = []
    for (let i = 0; i < financial_data_json[0].length; i++) {
      labels.push(`${financial_data_json[0][i]} kW/h`);
    }

    const dataColors = ['green', 'blue', 'yellow', 'red', 'orange', 'purple', 'pink', 'cyan', 'magenta', 'lime']

    // on génère les différents graphiques financiers (on avait un pb d'échelle pour mettre sur un seul)
    for (let i = 0; i < titles.length; i++) {
      // on itère sur le nb de scénarios
      var datasets_data = []
      var datasets_color = []
      for (let j = 0; j < financial_data_json[0].length; j++) {
        datasets_data.push(financial_data_json[i+1][j]),
        datasets_color.push(dataColors[j])
      };

      console.log(datasets_data, datasets_color)

      var data = {
        labels: labels,
        datasets: [{
          data: datasets_data,
          backgroundColor: datasets_color
        }]
      };

      var config = {
        type: 'bar',
        data: data,
        options: {
          plugins: {
            title: {
              display: true,
              text: titles[i]
            },
            legend: {
              display: false
            }
          }
        }
      };

      new Chart(
        this[`${this.constructor.targets[i+1]}Target`],
        config
      );
    }
  }
}
