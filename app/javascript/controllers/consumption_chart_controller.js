import { Controller } from "@hotwired/stimulus"
import { Chart } from "chart.js";

// Connects to data-controller="consumption-chart"
export default class extends Controller {
  connect() {
    console.log("hello from consumption chart controller JS")
  }
}
