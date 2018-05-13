<template>
  <div id="app">
    <img src="./assets/content_5.jpg">
    <br>
    <div class="columns">
      <div class="column">
        <button v-if="register" class="button is-primary" :class="{'is-loading': isRegistering}" @click="createTestator()"">Register</button>
        <div v-else>
          <p>Your address: {{ testator._address }}</p>
          <p>Your testamentum address: {{ testamentumAddress }}</p>
        </div>
      </div>
      <div class="column">
        <button class="button is-primary" :disabled="register" :class="{'is-loading': isCreateTestamentum}" @click="createTestamentum()">Create Testamentum</button>
      </div>
    </div>
  </div>
</template>

<script>

export default {
  name: 'app',
  data() {
    return {
      testator: null,
      testamentum: null,
      testamentumAddress: '',
      isRegistering: false,
      isCreateTestamentum: false
    }
  },
  computed: {
    register() {
      return (this.testator == null) || this.isRegistering;
    }
  },
  methods: {
    async createTestator() {
      this.isRegistering = true;
      this.testator = new web3.eth.Contract(this.$eth.testator.abi)
      let code = this.testator.deploy({data: this.$eth.testator.bytecode});

      this.testator = await code.send({from: web3.eth.defaultAccount});
      this.isRegistering = false;
    },

    async createTestamentum() {
      this.isCreateTestamentum = true;
      await this.testator.methods.newTestamentum().send({from: web3.eth.defaultAccount});
      this.testamentumAddress = await this.testator.methods.testamentum().call();
      console.log(this.testamentumAddress);
      this.testamentum = new web3.eth.Contract(this.$eth.testamentum.abi, this.testamentumAddress);
      this.isCreateTestamentum = false;
    }
  }
}
</script>

<style>
#app {
  font-family: 'Avenir', Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}
</style>
