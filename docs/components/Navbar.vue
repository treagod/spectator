<template>
  <nav
    class="navbar is-transparent"
    role="navigation"
    aria-label="main navigation"
  >
    <div class="container">
      <div class="navbar-brand">
        <NuxtLink class="navbar-item" to="/"
          ><img
            src="https://appstream.elementary.io/appcenter/media/bionic/com/github/treagod.spectator/84AB1F18324D910E1E4FA3A8FB0B7C9F/icons/64x64/com.github.treagod.spectator_com.github.treagod.spectator.png"
            alt="Spectator "
            height="120"
          /><span id="banner-text">Spectator</span></NuxtLink
        >

        <a
          role="button"
          class="navbar-burger"
          @click="showNav = !showNav" :class="{ 'is-active': showNav }"
        >
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
          <span aria-hidden="true"></span>
        </a>
      </div>

      <div id="navbarBasicExample" class="navbar-menu" :class="{ 'is-active': showNav }">
        <div class="navbar-start"></div>

        <div class="navbar-end">
          <!-- <NuxtLink class="navbar-item" to="/news">News</NuxtLink> -->
          <NuxtLink class="navbar-item" to="/docs">Documentation</NuxtLink>
          <a
            target="_blank"
            rel="noopener noreferrer"
            class="navbar-item"
            href="https://github.com/treagod/spectator"
            >Github</a
          >
        </div>
      </div>
    </div>
  </nav>
</template>

<script>
export default {
  data() {
    return {
      showNav: false
    }
  }
};
</script>

<style scoped>
.navbar {
  min-height: 4.5rem;
}

.navbar .navbar-item * {
  min-height: 2.5rem;
}

#banner-text {
  font-size: 22px;
  font-weight: bold;
  margin-left: 1em;
  font-family: Inter, Raleway, Inter, "Open Sans", "Noto Sans", "Roboto", "Droid Sans", sans-serif !important;
}

a.navbar-item:hover {
  color: #668e2c;
}
a.navbar-item:focus {
  color: #668e2c;
}
</style>