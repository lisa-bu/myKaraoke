import { Controller } from "@hotwired/stimulus";

// Track the currently playing controller instance across all instances
let currentlyPlayingController = null;

// Connects to data-controller="spotify-player"
export default class extends Controller {
  // 1. Define targets and values
  static targets = ["container", "button", "icon"];
  static values = { uri: String }; // To get the Spotify URI

  // Store the Spotify EmbedController instance
  embedController = null;
  isPlaying = false;

 connect() {
  console.log("Spotify player connected for URI:", this.uriValue);

  // Check if the API is already loaded
  if (window.IFrameAPI) {
    // API already loaded, initialize immediately
    this.initializePlayer(window.IFrameAPI);
  } else if (window.onSpotifyIframeApiReady) {
    const originalApiReady = window.onSpotifyIframeApiReady;
    window.onSpotifyIframeApiReady = (IFrameAPI) => {
      if (originalApiReady) {
        originalApiReady(IFrameAPI);
      }
      this.initializePlayer(IFrameAPI);
    };
  } else {
    window.onSpotifyIframeApiReady = (IFrameAPI) => {
      window.IFrameAPI = IFrameAPI; // Store for future use
      this.initializePlayer(IFrameAPI);
    };
  }
}

  // 3. Method to create and store the EmbedController
initializePlayer(IFrameAPI) {
  console.log("Initializing player with URI:", this.uriValue);

  if (!this.uriValue || this.uriValue === "spotify:track:") {
    console.error("Invalid Spotify URI - missing track ID");
    return;
  }

  const element = this.containerTarget;
  const options = {
    uri: this.uriValue,
    height: 0,
    width: 0,
  };

  // Add a small delay between initializations to avoid overwhelming Spotify's API
  setTimeout(() => {
    IFrameAPI.createController(element, options, (EmbedController) => {
      this.embedController = EmbedController;

      EmbedController.addListener("playback_update", (e) => {
        this.isPlaying = !e.data.isPaused;
        this.updateButtonIcon(e.data.isPaused);

        // Track which controller is currently playing
        if (this.isPlaying) {
          currentlyPlayingController = this;
        } else if (currentlyPlayingController === this) {
          currentlyPlayingController = null;
        }
      });

      this.updateButtonIcon(true);
      console.log("Player initialized successfully for:", this.uriValue);
    });
  }, Math.random() * 500); // Random delay 0-500ms to stagger initializations
}

  // 4. Action method called when the button is clicked
  togglePlay() {
    if (!this.embedController) {
      console.warn("Player not ready yet, trying to initialize...");
      // Disable button temporarily
      this.buttonTarget.disabled = true;
      this.buttonTarget.style.opacity = "0.5";

      if (window.IFrameAPI) {
        this.initializePlayer(window.IFrameAPI);
        // Try again after a delay
        setTimeout(() => {
          this.buttonTarget.disabled = false;
          this.buttonTarget.style.opacity = "1";
          if (this.embedController) {
            this.pauseOtherAndPlay();
          }
        }, 1000);
      }
      return;
    }

    this.pauseOtherAndPlay();
  }

  // Pause any other playing song before toggling this one
  pauseOtherAndPlay() {
    // If another song is playing, pause it first
    if (currentlyPlayingController && currentlyPlayingController !== this && currentlyPlayingController.isPlaying) {
      currentlyPlayingController.embedController.togglePlay();
    }

    this.embedController.togglePlay();
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
    // Clean up the currently playing reference if this controller was playing
    if (currentlyPlayingController === this) {
      currentlyPlayingController = null;
    }

    // Clean up the player when the controller is removed from the DOM
    if (this.embedController) {
      this.embedController.destroy();
    }
  }
}
