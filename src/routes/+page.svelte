<script>
  import { onMount } from 'svelte';

  let visitCount = null;
  let visitText = '';
  let newsItems = null;

  const isDev = localStorage.getItem('lk_dev');
  const isLocal = typeof window !== 'undefined' && window.location.protocol === 'file:';

  const visitEndpoint = "https://script.google.com/macros/s/AKfycbztKjPJahRvifOZBqlOA890PBXK5AqAqv2VksE7A1JlAHN84gQ98mxVjwDi98K6Sn6nsg/exec";
  const newsEndpoint = "https://script.google.com/macros/s/AKfycbzO8o3mKTDxHg5L2FGYe_ClEQtVZDy2HTW1JkXGsF5XJEbFNIoKejOU4jSDJGzMfqyXMg/exec";

  const images = [
    "AIKiwi1.png", "AIKiwi2.png", "AIKiwi3.png", "AIKiwi4.png",
    "AIKiwi10.png", "AIKiwi12.png", "AIKiwi13.png", "AIKiwi6.png",
    "AIKiwi8.png", "AIKiwi9.png"
  ];

  onMount(async () => {
    // Fetch visit count
    const visitURL = (!isDev && !isLocal) ? `${visitEndpoint}?increment=true` : visitEndpoint;
    try {
      const res = await fetch(visitURL);
      const data = await res.json();
      visitCount = data.visits ?? 0;
      visitText = `👁️ This page has been visited ${visitCount} times.` + ((isDev || isLocal) ? ' (dev mode or local: not counted)' : '');
    } catch {
      visitText = 'Unable to load visit count.';
    }

    // Fetch news
    try {
      const res = await fetch(newsEndpoint);
      const data = await res.json();
      newsItems = data.sort((a, b) => new Date(b.Date) - new Date(a.Date));
    } catch {
      newsItems = [];
    }
  });
</script>

<div class="home-content-placeholder">
  <h2 class="welcome">Welcome!</h2>
  <p class="description">
    I spent way too much time on this, but I enjoyed it very much. Made with Chat GPT because I have no idea how to code.
    Design tips and future additions can be submitted to me on discord. The point at present is just to facilitate a range
    of data display, (which I have managed to scrape from the Stratz website using the console commands and performed
    various manipulations on). I don't pretend it's perfectly accurate, but it's probably fairly good, and I'm quite proud of it :)
  </p>

  <p class="counter" id="visit-counter">{visitText}</p>

  <a href="https://discord.gg/YJcK4xXWvC" class="discord-button" target="_blank">Join Our Discord</a>
</div>

<div id="news-wrapper">
  <h3 class="news-title">News & Updates</h3>
  <div id="news-container">
    {#if newsItems === null}
      <p class="description">Loading news...</p>
    {:else if newsItems.length === 0}
      <p class="description">No news yet. Stay tuned!</p>
    {:else}
      {#each newsItems as item}
        <div class="news-entry">
          <div class="news-heading">{item.Date.split('T')[0]} - {item.Title}</div>
          <div class="news-body">{item.Content}</div>
        </div>
      {/each}
    {/if}
  </div>
</div>

<div class="gallery-section">
  <h3 class="gallery-title">AI Kiwi Gallery</h3>
  <div class="gallery-grid">
    {#each images as image}
      <div class="gallery-item">
        <img src={`/home_gallery_assets/${image}`} alt={image} />
      </div>
    {/each}
  </div>
</div>

<style>
  @import url('https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700&display=swap');

  .home-content-placeholder {
    text-align: center;
    color: #00FF00;
    font-family: 'Orbitron', sans-serif;
    margin: 30px auto;
    max-width: 720px;
    background-color: black;
  }

  .welcome {
    font-size: 30px;
    text-shadow: 0 0 10px #00FF00;
    margin-bottom: 18px;
  }

  .description {
    font-size: 16px;
    line-height: 1.5;
    margin: 0 auto 12px;
    max-width: 640px;
  }

  .counter {
    margin: 18px auto;
    font-size: 16px;
    color: #00FF00;
  }

  .discord-button {
    display: inline-block;
    padding: 12px 24px;
    background-color: #ab6e11;
    color: #000;
    font-weight: bold;
    font-size: 16px;
    border-radius: 6px;
    margin-top: 14px;
    box-shadow: 0 0 8px #ab6e11;
    text-decoration: none;
    transition: all 0.2s ease;
    font-family: 'Orbitron', sans-serif;
  }

  .discord-button:hover {
    background-color: #d28822;
    box-shadow: 0 0 12px #ab6e11;
  }

  #news-wrapper {
    margin: 60px auto;
    max-width: 720px;
    border: 2px solid #00FF00;
    padding: 24px;
    box-shadow: 0 0 14px #00FF00;
    background-color: black;
    font-family: 'Orbitron', sans-serif;
  }

  .news-title {
    color: #00FF00;
    font-size: 22px;
    text-align: center;
    margin-bottom: 20px;
    text-shadow: 0 0 8px #00FF00;
  }

  #news-container {
    max-height: 360px;
    overflow-y: auto;
    padding-right: 12px;
    scrollbar-color: #00FF00 #000;
    scrollbar-width: thin;
  }

  .news-entry {
    margin-bottom: 22px;
  }

  .news-heading {
    color: #ab6e11;
    font-size: 17px;
    font-weight: bold;
    text-shadow: 0 0 4px #ab6e11;
    margin-bottom: 4px;
  }

  .news-body {
    color: #00FF00;
    font-size: 15.5px;
    line-height: 1.5;
    margin-left: 4px;
  }

  .gallery-section {
    margin: 60px auto;
    max-width: 900px;
    text-align: center;
    font-family: 'Orbitron', sans-serif;
  }

  .gallery-title {
    font-size: 22px;
    color: #00FF00;
    margin-bottom: 20px;
    text-shadow: 0 0 8px #00FF00;
  }

  .gallery-grid {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    gap: 16px;
  }

  .gallery-item {
    width: 21%;
    max-width: 200px;
    min-width: 160px;
    aspect-ratio: 3/4;
    display: flex;
    align-items: center;
    justify-content: center;
  }

  .gallery-item img {
    width: 100%;
    height: auto;
    border: 2px solid #00FF00;
    box-shadow: 0 0 8px #00FF00;
    transition: transform 0.2s ease, box-shadow 0.2s ease;
  }

  .gallery-item img:hover {
    transform: scale(1.08);
    box-shadow: 0 0 16px #00FF00;
  }

  @media (max-width: 800px) {
    .gallery-item {
      width: 30%;
    }
  }

  @media (max-width: 500px) {
    .gallery-item {
      width: 45%;
    }
  }

  /* FULL PAGE BACKGROUND FIX */
  :global(body) {
    background-color: black;
    margin: 0;
    padding: 0;
  }

  :global(html) {
    background-color: black;
    height: 100%;
  }
</style>
