<script>
  import { onMount } from 'svelte';

  let leaderboardData = {};
  let totalData = {};
  let weeks = [];
  let selectedWeek = '';
  let showExtraCols = false;
  let currentSort = { column: 'gain', descending: true };
  let loading = true;

  const endpoint = 'https://script.google.com/macros/s/AKfycbxCm2fdYwdu-EHsDAT2AxnO6NsZ2d_mkg-4Meke-FTRBxTGEF5AmwLPifcbFOn5lYQY/exec';

  onMount(async () => {
    try {
      const res = await fetch(endpoint);
      const json = await res.json();
      leaderboardData = json.gains;
      totalData = json.totals;
      const firstPlayer = Object.keys(leaderboardData)[0];
      weeks = Object.keys(leaderboardData[firstPlayer] || {}).filter(w => w !== '21/02')
        .sort((a, b) => new Date(a.split('/').reverse().join('/')) - new Date(b.split('/').reverse().join('/')));
      selectedWeek = weeks.at(-1);
      loading = false;
    } catch (e) {
      console.error('Failed to fetch or parse leaderboard data:', e);
    }
  });

  function computeAverage(player, currentWeek, sortedWeeks) {
    const index = sortedWeeks.indexOf(currentWeek);
    const validWeeks = sortedWeeks.slice(0, index + 1);
    const scores = validWeeks.map(w => parseInt(leaderboardData[player]?.[w] || 0)).filter(x => x > 0);
    const recent = scores.slice(-4);
    const avg = recent.length ? Math.round(recent.reduce((a, b) => a + b, 0) / recent.length) : 0;

    const prevIndex = index - 1;
    const prevValidWeeks = sortedWeeks.slice(0, prevIndex + 1);
    const prevScores = prevValidWeeks.map(w => parseInt(leaderboardData[player]?.[w] || 0)).filter(x => x > 0);
    const prevRecent = prevScores.slice(-4);
    const prevAvg = prevRecent.length ? Math.round(prevRecent.reduce((a, b) => a + b, 0) / prevRecent.length) : 0;

    return {
      avg,
      prevAvg,
      note: recent.length < 4,
      raw: avg
    };
  }

  $: tableData = [];
  $: if (!loading && selectedWeek) {
    const sortedWeeks = weeks;
    tableData = Object.keys(leaderboardData).map(name => {
      const gain = parseInt(leaderboardData[name]?.[selectedWeek] ?? 0);
      if (leaderboardData[name]?.[selectedWeek] === undefined) return null;
      const { avg, prevAvg, note, raw } = computeAverage(name, selectedWeek, sortedWeeks);
      return {
        name,
        gain,
        total: parseInt(totalData[name]?.[selectedWeek] || 0),
        avgDisplay: note ? avg + '*' : avg,
        avgSort: raw,
        prevAvg,
        note
      };
    }).filter(Boolean);

    const topAvg = [...tableData].sort((a, b) => b.avgSort - a.avgSort).slice(0, 3).map(p => p.name);
    const legendarySet = new Set(topAvg);

    tableData.sort((a, b) => {
      const aVal = currentSort.column === 'avg' ? a.avgSort : a[currentSort.column];
      const bVal = currentSort.column === 'avg' ? b.avgSort : b[currentSort.column];
      return currentSort.descending ? bVal - aVal : aVal - bVal;
    });

    tableData.forEach(row => {
      row.glowClass = row.avgSort >= row.prevAvg ? 'green-glow' : 'red-glow';
      if (legendarySet.has(row.name)) {
        row.badgeClass = 'top3';
        row.label = 'Legendary';
      } else if (row.avgSort > 2000) {
        row.badgeClass = 'thriving';
        row.label = 'Thriving';
      } else if (row.avgSort >= 1000) {
        row.badgeClass = 'holding';
        row.label = 'Struggling';
      } else {
        row.badgeClass = 'danger';
        row.label = 'Critical';
      }
    });
  }

  function updateSort(column) {
    if (currentSort.column === column) {
      currentSort.descending = !currentSort.descending;
    } else {
      currentSort = { column, descending: true };
    }
  }
</script>

<h1 class="title">Weekly Guild Point Leaderboard</h1>
{#if loading}
  <p class="blinker">Loading guild data...</p>
{:else}
  <div class="controls">
    <select bind:value={selectedWeek}>
      {#each weeks as w}<option value={w}>{w}</option>{/each}
    </select>
    <button on:click={() => showExtraCols = !showExtraCols}>Toggle Totals + Avg</button>
  </div>

  <div class="datapad">
    <table>
      <thead>
        <tr>
          <th>#</th>
          <th class="sortable" on:click={() => updateSort('name')}>Player</th>
          <th class="sortable" on:click={() => updateSort('gain')}>Points</th>
          {#if showExtraCols}
            <th class="sortable" on:click={() => updateSort('total')}>Total</th>
            <th class="sortable" on:click={() => updateSort('avg')}>4-Week Avg</th>
          {/if}
          <th>Health Check</th>
        </tr>
      </thead>
      <tbody>
        {#each tableData as row, i}
          <tr>
            <td>{i + 1}</td>
            <td>{row.name}</td>
            <td>{row.gain}</td>
            {#if showExtraCols}
              <td>{row.total}</td>
              <td>{row.avgDisplay}</td>
            {/if}
            <td>
              <span class={`health ${row.badgeClass} ${row.glowClass} glitch`}>
                {row.label}
                {#if row.note}<span title="Less than 4 weeks data" style="color: #ab6e11;">*</span>{/if}
              </span>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>

  <p class="legend">
    <span class="health top3">Legendary</span>
    <span class="health thriving">Thriving</span>
    <span class="health holding">Struggling</span>
    <span class="health danger">Critical</span><br>
    🟢 Green glow = Avg increased or unchanged from previous week<br>
    🔴 Red glow = Avg decreased from previous week<br>
    <em style="color: #ab6e11;">* = less than 4 weeks data</em>
  </p>
{/if}

<style>
  .title {
    color: #00FF00;
    text-shadow: 0 0 6px #00FF00;
    text-align: center;
    font-size: 32px;
    margin-bottom: 1rem;
    font-family: 'Orbitron', sans-serif;
  }

  .controls {
    display: flex;
    justify-content: center;
    gap: 1rem;
    margin-bottom: 1rem;
  }

  select, button {
    background: black;
    color: #00FF00;
    border: 2px solid #00FF00;
    padding: 6px 12px;
    font-family: 'Orbitron', sans-serif;
    font-size: 16px;
    box-shadow: 0 0 6px #00FF00;
  }

  .datapad {
    margin: auto;
    padding: 1rem;
    background: rgba(0, 255, 0, 0.03);
    border: 2px solid #00FF00;
    box-shadow: inset 0 0 8px #ab6e11, 0 0 12px #00FF00;
    border-radius: 10px;
    width: fit-content;
    overflow-x: auto;
  }

  table {
    border-collapse: collapse;
    font-family: 'Orbitron', sans-serif;
    font-size: 14px;
    color: #00FF00;
    width: 100%;
  }

  th, td {
    border: 1px solid rgba(171, 110, 17, 0.6); /* burnt orange faded */
    padding: 8px 12px;
    text-align: center;
    background: rgba(0, 0, 0, 0.6);
  }

  th {
    color: #00FF00; /* neon green headers */
    border-bottom: 2px solid #00FF00;
  }

  th.sortable {
    cursor: pointer;
    text-decoration: underline;
  }

  th.sortable:hover {
    color: #00FF00;
  }

  .health {
    position: relative;
    display: inline-block;
    padding: 4px 12px;
    border-radius: 999px;
    font-weight: bold;
    font-size: 13px;
    color: black;
    transition: box-shadow 0.3s ease;
    overflow: hidden;
  }

  .top3 {
    background: linear-gradient(90deg, #ff00ff, #00ffff, #ff00ff);
    color: black;
  }

  .thriving {
    background: #00FF00;
    color: black;
  }

  .holding {
    background: #ffaa00;
    color: #ab6e11;
  }

  .danger {
    background: #ff0033;
    color: #ab6e11;
  }

  .green-glow {
    animation: pulse-green 2s infinite;
  }

  .red-glow {
    animation: pulse-red 1s infinite;
  }

  @keyframes pulse-green {
    0%, 100% { box-shadow: 0 0 6px #00FF00; }
    50% { box-shadow: 0 0 14px #00FF00; }
  }

  @keyframes pulse-red {
    0%, 100% { box-shadow: 0 0 4px #ff0033; }
    50% { box-shadow: 0 0 12px #ff0033; }
  }

  /* New glitch animation on background */
  .glitch::before {
    content: "";
    position: absolute;
    inset: 0;
    background: repeating-linear-gradient(
      0deg,
      rgba(255,255,255,0.05) 0,
      rgba(255,255,255,0.05) 1px,
      transparent 1px,
      transparent 3px
    );
    animation: glitch-stripes 3s linear infinite;
    pointer-events: none;
    z-index: 0;
  }

  .glitch::after {
    content: "";
    position: absolute;
    inset: 0;
    background:
      linear-gradient(
        120deg,
        transparent 0%,
        rgba(255, 255, 255, 0.15) 50%,
        transparent 100%
      );
    transform: skewX(-15deg);
    animation: glitch-scan 4s linear infinite;
    pointer-events: none;
    z-index: 1;
  }

  @keyframes glitch-stripes {
    0% { background-position-y: 0; }
    100% { background-position-y: 100%; }
  }

  @keyframes glitch-scan {
    0% { left: -20%; }
    100% { left: 120%; }
  }

  .legend {
    text-align: center;
    font-size: 14px;
    color: #00FF00;
    margin-top: 1rem;
    line-height: 1.6;
  }

  .blinker {
    animation: blinker 1.2s step-start infinite;
    text-align: center;
    color: #00FF00;
  }

  @keyframes blinker {
    50% { opacity: 0; }
  }
</style>
