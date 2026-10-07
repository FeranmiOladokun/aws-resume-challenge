// Send one counter request each time this page loads.
async function updateCounter() {
  const count = document.getElementById("visitor-count");
  const endpoint = "https://7xdl6stl3zys4twtvps4bhmvpu0gszso.lambda-url.us-east-1.on.aws/";

  try {
    const response = await fetch(endpoint, { cache: "no-store" });
    if (!response.ok) throw new Error("Counter request failed");

    const data = await response.json();
    if (!Number.isSafeInteger(data.views) || data.views < 0) {
      throw new Error("Invalid counter response");
    }
    count.textContent = data.views.toLocaleString();
  } catch (error) {
    count.textContent = "Unavailable";
    console.error("Could not load page views:", error);
  }
}

updateCounter();
