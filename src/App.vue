<script setup lang="ts">
import { computed, ref } from 'vue'

interface ProjectionPoint {
  year: number
  fixed: number
  stepped: number
}

const monthlySalary = ref(100_000)
const currentSip = ref(10_000)
const annualRaise = ref(10)
const expectedReturn = ref(12)
const years = ref(20)

const clamp = (value: number, minimum: number, maximum: number) =>
  Math.min(Math.max(Number.isFinite(value) ? value : minimum, minimum), maximum)

const projection = computed(() => {
  const duration = Math.round(clamp(Number(years.value), 5, 40))
  const salaryGrowth = clamp(Number(annualRaise.value), 0, 50) / 100
  const monthlyRate = clamp(Number(expectedReturn.value), 0, 30) / 100 / 12
  const baseSip = clamp(Number(currentSip.value), 0, 10_000_000)
  let salary = clamp(Number(monthlySalary.value), 0, 100_000_000)
  let steppedSip = baseSip
  let fixedCorpus = 0
  let steppedCorpus = 0
  let fixedInvested = 0
  let steppedInvested = 0
  const points: ProjectionPoint[] = [{ year: 0, fixed: 0, stepped: 0 }]

  for (let year = 1; year <= duration; year += 1) {
    for (let month = 0; month < 12; month += 1) {
      fixedCorpus = fixedCorpus * (1 + monthlyRate) + baseSip
      steppedCorpus = steppedCorpus * (1 + monthlyRate) + steppedSip
      fixedInvested += baseSip
      steppedInvested += steppedSip
    }

    points.push({ year, fixed: fixedCorpus, stepped: steppedCorpus })

    if (year < duration) {
      const newSalary = salary * (1 + salaryGrowth)
      steppedSip += (newSalary - salary) * 0.7
      salary = newSalary
    }
  }

  return {
    duration,
    fixedCorpus,
    steppedCorpus,
    fixedInvested,
    steppedInvested,
    finalMonthlySip: steppedSip,
    difference: steppedCorpus - fixedCorpus,
    points,
  }
})

const compactCurrency = new Intl.NumberFormat('en-IN', {
  style: 'currency',
  currency: 'INR',
  notation: 'compact',
  maximumFractionDigits: 1,
})

const fullCurrency = new Intl.NumberFormat('en-IN', {
  style: 'currency',
  currency: 'INR',
  maximumFractionDigits: 0,
})

const formatCompact = (value: number) => compactCurrency.format(value)
const formatFull = (value: number) => fullCurrency.format(Math.round(value))

const chart = computed(() => {
  const width = 760
  const height = 280
  const maxValue = Math.max(projection.value.steppedCorpus, 1)
  const lastIndex = Math.max(projection.value.points.length - 1, 1)
  const pointString = (key: 'fixed' | 'stepped') =>
    projection.value.points
      .map((point, index) => {
        const x = (index / lastIndex) * width
        const y = height - (point[key] / maxValue) * (height - 12)
        return `${x.toFixed(1)},${y.toFixed(1)}`
      })
      .join(' ')

  return {
    fixed: pointString('fixed'),
    stepped: pointString('stepped'),
    area: `0,${height} ${pointString('stepped')} ${width},${height}`,
    max: maxValue,
  }
})
</script>

<template>
  <div class="site-shell">
    <header class="site-header">
      <a class="brand" href="#" aria-label="StepUp home">
        <span class="brand-mark" aria-hidden="true">S</span>
        <span>STEPUP</span>
      </a>

      <a class="header-link" href="#calculator">Try the calculator <span aria-hidden="true">↘</span></a>
    </header>

    <main>
      <section class="hero" aria-labelledby="hero-title">
        <div class="hero-heading">
          <p class="eyebrow">The 70% step-up rule</p>
          <h1 id="hero-title">Give your raise<br /><em>a better job.</em></h1>
        </div>

        <div class="hero-aside">
          <p class="hero-stat"><strong>70%</strong> of every salary increase</p>
          <p class="hero-copy">
            Move it into your monthly SIP. You still keep 30% of the raise, while every future increase compounds your wealth.
          </p>
          <a class="primary-link" href="#calculator">See your projection <span aria-hidden="true">↓</span></a>
        </div>
      </section>

      <section class="rule-strip" aria-label="The 70 percent rule summary">
        <p><span>Salary goes up</span><strong>+10%</strong></p>
        <span class="rule-arrow" aria-hidden="true">→</span>
        <p><span>Send to SIP</span><strong>70%</strong></p>
        <span class="rule-arrow" aria-hidden="true">→</span>
        <p><span>Keep to spend</span><strong>30%</strong></p>
      </section>

      <section id="calculator" class="calculator-section" aria-labelledby="calculator-title">
        <div class="section-intro">
          <p class="eyebrow">Run the numbers</p>
          <h2 id="calculator-title">One habit.<br />Two futures.</h2>
          <p>Adjust the assumptions to see how consistently redirecting 70% of each raise changes your long-term corpus.</p>
        </div>

        <div class="calculator">
          <form class="controls" @submit.prevent>
            <div class="control-row">
              <label for="salary">Monthly take-home salary</label>
              <div class="input-shell">
                <span>₹</span>
                <input id="salary" v-model.number="monthlySalary" type="number" min="0" max="100000000" step="5000" inputmode="decimal" />
              </div>
            </div>

            <div class="control-row">
              <label for="sip">Current monthly SIP</label>
              <div class="input-shell">
                <span>₹</span>
                <input id="sip" v-model.number="currentSip" type="number" min="0" max="10000000" step="1000" inputmode="decimal" />
              </div>
            </div>

            <div class="control-pair">
              <div class="control-row">
                <label for="raise">Annual salary increase</label>
                <div class="input-shell">
                  <input id="raise" v-model.number="annualRaise" type="number" min="0" max="50" step="0.5" inputmode="decimal" />
                  <span>%</span>
                </div>
              </div>

              <div class="control-row">
                <label for="return">Expected annual return</label>
                <div class="input-shell">
                  <input id="return" v-model.number="expectedReturn" type="number" min="0" max="30" step="0.5" inputmode="decimal" />
                  <span>%</span>
                </div>
              </div>
            </div>

            <fieldset class="horizon-control">
              <legend>Investment period</legend>
              <div class="year-presets" aria-label="Common investment periods">
                <button type="button" :class="{ active: years === 20 }" @click="years = 20">20 years</button>
                <button type="button" :class="{ active: years === 25 }" @click="years = 25">25 years</button>
                <output for="years">{{ years }} years</output>
              </div>
              <input id="years" v-model.number="years" class="range" type="range" min="5" max="40" step="1" />
              <div class="range-labels"><span>5 years</span><span>40 years</span></div>
            </fieldset>

            <p class="assumption">The step-up happens once a year. Returns are compounded monthly.</p>
          </form>

          <div class="results" aria-live="polite">
            <div class="result-heading">
              <p>Projected corpus after {{ projection.duration }} years</p>
              <span>At {{ expectedReturn }}% assumed return</span>
            </div>

            <div class="result-comparison">
              <article class="result-card fixed-result">
                <div class="result-label"><span class="legend-dot fixed"></span>Without step-up</div>
                <strong>{{ formatCompact(projection.fixedCorpus) }}</strong>
                <p>{{ formatCompact(projection.fixedInvested) }} invested</p>
              </article>

              <article class="result-card stepped-result">
                <div class="result-label"><span class="legend-dot stepped"></span>With the 70% rule</div>
                <strong>{{ formatCompact(projection.steppedCorpus) }}</strong>
                <p>{{ formatCompact(projection.steppedInvested) }} invested</p>
              </article>
            </div>

            <div class="chart-wrap">
              <div class="chart-axis" aria-hidden="true">
                <span>{{ formatCompact(chart.max) }}</span>
                <span>{{ formatCompact(chart.max / 2) }}</span>
                <span>₹0</span>
              </div>
              <svg class="chart" viewBox="0 0 760 280" role="img" :aria-label="`Corpus growth over ${projection.duration} years with and without the 70 percent SIP step-up rule`" preserveAspectRatio="none">
                <line x1="0" y1="1" x2="760" y2="1" />
                <line x1="0" y1="140" x2="760" y2="140" />
                <line x1="0" y1="279" x2="760" y2="279" />
                <polygon :points="chart.area" class="chart-area" />
                <polyline :points="chart.fixed" class="chart-line chart-fixed" />
                <polyline :points="chart.stepped" class="chart-line chart-stepped" />
              </svg>
              <div class="chart-years"><span>Today</span><span>Year {{ projection.duration }}</span></div>
            </div>

            <div class="impact">
              <p>Your potential difference</p>
              <strong>+{{ formatCompact(projection.difference) }}</strong>
              <span>Final monthly SIP: {{ formatFull(projection.finalMonthlySip) }}</span>
            </div>
          </div>
        </div>
      </section>

      <section class="explanation" aria-labelledby="explanation-title">
        <div class="explanation-heading">
          <p class="eyebrow">Why it works</p>
          <h2 id="explanation-title">Grow your investments before your lifestyle grows into the gap.</h2>
        </div>

        <div class="explanation-grid">
          <article>
            <span>01</span>
            <h3>Start with your raise</h3>
            <p>A higher salary creates new room in your budget without asking you to cut what you already spend.</p>
          </article>
          <article>
            <span>02</span>
            <h3>Redirect 70%</h3>
            <p>Increase your monthly SIP by 70% of the raise and keep the remaining 30% for today.</p>
          </article>
          <article>
            <span>03</span>
            <h3>Repeat every year</h3>
            <p>Each step-up gets more years to compound, turning a simple annual decision into a larger long-term corpus.</p>
          </article>
        </div>
      </section>
    </main>

    <footer class="site-footer">
      <p>Step up the raise. Keep the habit.</p>
      <p class="disclaimer">Illustrative projections only. Market returns are not guaranteed.</p>
    </footer>
  </div>
</template>
