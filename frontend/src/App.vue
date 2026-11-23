<script setup>
import logo from './assets/logo.png'
import icon from './assets/logo-icon.png'

const links = ['Kezdőlap', 'Projektek', 'Súgó']
</script>

<template>
  <header class="navbar">
    <a href="/" class="brand"><img :src="logo" alt="Boardly" /></a>
    <nav>
      <a v-for="(link, i) in links" :key="link" href="#" :class="{ active: i === 0 }">{{ link }}</a>
    </nav>
    <a href="#" class="btn">Bejelentkezés</a>
  </header>

  <main class="main">
    <img :src="icon" alt="" class="icon" />
  </main>
</template>
