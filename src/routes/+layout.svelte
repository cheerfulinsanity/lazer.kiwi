<!-- +layout.svelte -->
<script>
  import { onMount } from 'svelte';
</script>

<!-- Page Layout Wrapper -->
<div class="layout-wrapper">
  <img src="/home_gallery_assets/Banner.png" alt="Lazer Kiwi Banner" class="banner" />

  <nav class="tab-bar">
    <a href="/" class="tab-button">Home</a>
    <a href="/turbo-graphs" class="tab-button">Turbo Rank Graphs</a>
    <a href="/party-estimator" class="tab-button">Party Rank Estimator</a>
    <a href="/weekly-leaderboard" class="tab-button">Weekly Point Leaderboard</a>
    <a href="/weekly-graphs" class="tab-button">Weekly Point Graphs</a>
    <a href="/guild-rank-list" class="tab-button">Guild Rank List</a>
  </nav>

  <!-- THIS LINE IS CRUCIAL -->
  <slot />
</div>

<style>
  /* Global Reset Fix */
  :global(body) {
    margin: 0;
    background-color: black;
  }

  .layout-wrapper {
    background-color: black;
    color: #00FF00;
    font-family: 'Orbitron', sans-serif;
    min-height: 100vh;
  }

  .banner {
    width: 100%;
    display: block;
    border-bottom: 2px solid #00FF00;
  }

  .tab-bar {
    background-color: black;
    border-top: 2px solid #00FF00;
    border-bottom: 2px solid #00FF00;
    padding: 10px;
    display: flex;
    justify-content: center;
    flex-wrap: wrap;
    gap: 10px;
  }

  .tab-button {
    background-color: black;
    color: #00FF00;
    font-weight: bold;
    border: 2px solid #00FF00;
    padding: 6px 12px;
    border-radius: 5px;
    text-decoration: none;
    box-shadow: 0 0 8px #00FF00;
    transition: all 0.2s ease;
  }

  .tab-button:hover {
    background-color: #00FF00;
    color: black;
    text-shadow: none;
  }
</style>
