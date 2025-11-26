document.addEventListener("input", async (e) => {
  if (e.target.id !== "spotify-search") return;

  const q = e.target.value;
  if (q.length < 2) return;

  const res = await fetch(`/search?q=${encodeURIComponent(q)}`);
  const tracks = await res.json();

  const container = document.getElementById("results");
  container.innerHTML = "";

  tracks.forEach(track => {
    const div = document.createElement("div");
    div.innerHTML = `
      <img src="${track.image}" width="60" />
      <strong>${track.name}</strong>
      <span>${track.artist}</span>
    `;
    div.classList.add("track-item");
    container.appendChild(div);

    div.onclick = () => {
      // Can try figure this out later
      console.log("Selected track:", track.uri);
    }
  });
});
