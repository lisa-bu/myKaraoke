import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="spotify-player"
export default class extends Controller {
  // 1. Define targets and values
  static targets = ["container", "button", "icon"];
  static values = { uri: String }; // To get the Spotify URI

  // Store the Spotify EmbedController instance
  embedController = null;

  connect() {
    // 2. Load the Spotify iFrame API
    // We rely on the script being loaded on the page (from <script> tag in HTML)

    if (window.onSpotifyIframeApiReady) {
      // Temporarily store the original function if it exists
      const originalApiReady = window.onSpotifyIframeApiReady;
      window.onSpotifyIframeApiReady = (IFrameAPI) => {
        // Run the original function first, if any
        if (originalApiReady) {
          originalApiReady(IFrameAPI);
        }

        // Then, initialize this specific player
        this.initializePlayer(IFrameAPI);
      };
    } else {
      // If no other player has defined the callback yet, define it here
      window.onSpotifyIframeApiReady = (IFrameAPI) => {
        this.initializePlayer(IFrameAPI);
      };
    }
  }

  // 3. Method to create and store the EmbedController
  initializePlayer(IFrameAPI) {
    const element = this.containerTarget;
    const options = {
      uri: this.uriValue,
      height: 0, // Set height to 0 to keep it hidden, just in case 'hidden' attribute is removed
      width: 0, // Set width to 0 to keep it hidden
    };

    // Create the controller instance
    IFrameAPI.createController(element, options, (EmbedController) => {
      this.embedController = EmbedController;

      // Listen for playback state changes to update the button text
      EmbedController.addListener("playback_update", (e) => {
        this.updateButtonIcon(e.data.isPaused);
      });

      // Initial state update
      this.updateButtonIcon(true);
    });
  }

  // 4. Action method called when the button is clicked
  togglePlay() {
    if (this.embedController) {
      this.embedController.togglePlay();
      // The button text will be updated by the 'playback_update' listener
    }
  }

  // 5. Helper to update button text
 updateButtonIcon(isPaused) {
  if (isPaused) {
    this.iconTarget.classList.remove("fa-pause");
    this.iconTarget.classList.add("fa-play");
  } else {
    this.iconTarget.classList.remove("fa-play");
    this.iconTarget.classList.add("fa-pause");
  }
}

  disconnect() {
    // Optional: Clean up the player when the controller is removed from the DOM
    if (this.embedController) {
      this.embedController.destroy();
    }
  }
}
