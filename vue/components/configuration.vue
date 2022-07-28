<template>
  <div class="configuration">
    <a-form>
      <template v-if="type === 'server'">
        <h3>{{ name }} Server Configuaration</h3>
      </template>
      <template v-if="type === 'client'">
        <h3>{{ name }} Client Configuaration</h3>
      </template>
      <a-divider />
      <!-- surasyti skirtingus configuracijos fieldus -->
    </a-form>
  </div>
</template>
<script>
export default {
  name: 'Configuaration',
  props: {
    type: String,
    name: String
  }
}
</script>
