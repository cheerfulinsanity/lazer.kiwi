<script>
  import { onMount } from 'svelte';
  import { rankNumberToLabel } from '$lib/constants.js';

  const selects = ['player1', 'player2', 'player3', 'player4', 'player5'];
  let rankData = {};
  let playerNames = [];
  let result = '';
  let loading = true;

  onMount(async () => {
    const endpoints = [
      "https://script.google.com/macros/s/AKfycbzjviloMAM-KHYnkDDiPiFvR-nqDqauAm2XAsHWolH4JTWloINQ8tWGrO17GwHFKKP1Ow/exec",
      "https://script.google.com/macros/s/AKfycbzSbehUm4C_SqZT3_ol8--cwDR-ADzc0qvUJ09UA9pMuu1-Um9oYdDhY-Ry5tk4_SxC/exec"
    ];

    const results = await Promise.all(endpoints.map(url => fetch(url).then(res => res.json())));

    results.forEach(data => {
      for (const player in data) {
        const val = data[player];
        if (typeof val === 'number') {
          rankData[player] = val;
        } else if (typeof val === 'object') {
          const dates = Object.keys(val).sort((a, b) => new Date(b) - new Date(a));
          for (const date of dates) {
            if (val[date] !== null) {
              rankData[player] = val[date];
              break;
            }
          }
        }
      }
    });

    playerNames = Object.keys(rankData).sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base' }));
    loading = false;
  });

  function calculateAverage() {
    const selected = selects.map(id => document.getElementById(id)?.value).filter(Boolean);
    if (!selected.length) {
      result = "Please select at least one player.";
      return;
    }

    const values = selected.map(name => rankData[name]).filter(val => typeof val === 'number');
    if (!values.length) {
      result = "No valid rank data available.";
      return;
    }

    const avg = values.reduce((a, b) => a + b, 0) / values.length;
    result = `Estimated Rank: ${rankNumberToLabel(Math.round(avg))}`;
  }
</script>

<svelte:head>
  <link href="https://fonts.googleapis.com/css2?family=Orbitron&display=swap" rel="stylesheet" />
</svelte:head>

<h2 class="glow">Party Average Rank Estimator</h2>

<p class="description">
  Turbo Rank data is approximate for guild members who have not exposed their public match data.
  If you want your rank to be more accurate, expose your match data in the Dota 2 Social settings,
  and let the Bag of Dicks know. Data is based on an average of the rank of your last 15 solo turbo games.
</p>

{#if loading}
  <div class="loading-message">Fetching Turbo Rank Data<span class="dots">...</span></div>
{:else}
  <div class="container">
    {#each selects as id}
      <select id={id}>
        <option value="">-- Select Player --</option>
        {#each playerNames as name}
          <option value={name}>{name}</option>
        {/each}
      </select>
    {/each}

    <button on:click={calculateAverage}>Estimate Rank</button>

    <div class="result-display">{result}</div>
  </div>
{/if}

<style>
  :global(body) {
    font-family: 'Orbitron', sans-serif;
    background-color: black;
    color: #00FF00;
  }

  h2.glow {
    font-size: 32px;
    text-align: center;
    text-shadow: 0 0 8px #00FF00;
    margin-top: 20px;
  }

  .description {
    font-size: 16px;
    line-height: 1.6;
    text-align: center;
    max-width: 850px;
    margin: 0 auto 30px;
    color: #00FF00;
  }

  .loading-message {
    text-align: center;
    margin-top: 60px;
    font-size: 20px;
    color: #00FF00;
    text-shadow: 0 0 6px #00FF00;
    font-family: 'Orbitron', sans-serif;
  }

  .dots::after {
    content: '';
    display: inline-block;
    width: 1ch;
    animation: blink 1.5s steps(3, end) infinite;
  }

  @keyframes blink {
    0% { content: ''; }
    33% { content: '.'; }
    66% { content: '..'; }
    100% { content: '...'; }
  }

  .container {
    display: flex;
    flex-direction: column;
    align-items: center;
    padding-bottom: 120px;
  }

  select {
    margin: 8px;
    background: #000;
    color: #00FF00;
    border: 2px solid #ab6e11;
    font-size: 16px;
    padding: 8px 10px;
    width: 320px;
    border-radius: 4px;
    box-shadow: 0 0 8px #00FF00;
    font-family: 'Orbitron', sans-serif;
    text-align: center;
  }

  button {
    background-color: #ab6e11;
    color: black;
    margin-top: 20px;
    padding: 10px 20px;
    font-size: 16px;
    border: none;
    cursor: pointer;
    border-radius: 6px;
    box-shadow: 0 0 8px #00FF00;
    font-family: 'Orbitron', sans-serif;
  }

  button:hover {
    background-color: #e07b12;
  }

  .result-display {
    margin-top: 20px;
    font-size: 20px;
    font-weight: bold;
    color: #00FF00;
    text-shadow: 0 0 6px #00FF00;
  }
</style>
