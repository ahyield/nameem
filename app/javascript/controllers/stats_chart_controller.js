import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["canvas"]
  static values = { labels: Array, views: Array, visitors: Array }

  async connect() {
    const mod = await import("chart.js")
    const Chart = mod.default || mod.Chart || mod

    new Chart(this.canvasTarget, {
      type: "bar",
      data: {
        labels: this.labelsValue,
        datasets: [
          {
            label: "المشاهدات",
            data: this.viewsValue,
            backgroundColor: "rgba(59, 130, 246, 0.7)"
          },
          {
            label: "الزوار",
            data: this.visitorsValue,
            backgroundColor: "rgba(20, 184, 166, 0.7)"
          }
        ]
      },
      options: {
        responsive: true,
        scales: {
          y: { beginAtZero: true, ticks: { precision: 0 } }
        },
        plugins: {
          legend: { position: "bottom" }
        }
      }
    })
  }
}
