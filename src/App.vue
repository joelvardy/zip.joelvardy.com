<template>
  <div id="app">
    <h1>Generate Zip Files</h1>
    <p>Select files and generate a Zip containing them</p>
    <label v-bind:class="loading ? 'upload loading' : 'upload'">
      <input type="file" multiple ref="files" v-on:change="handleFileSelection()" />
      <span>Select Files</span>
    </label>
    <h3 v-if="complete && !files.length">Your files have been processed and your Zip is downloading</h3>
    <div v-if="files.length">
      <div class="files">
        <div class="file" v-for="(file, i) in files" v-bind:key="i">
          <span class="name">{{ file.name }} ({{ filesize(file) }})</span>
          <button v-on:click="removeFile(i)">✕</button>
        </div>
      </div>
      <h3
        v-if="totalSelectedFilesSize > 250000000"
      >Be aware with larger Zips it will take longer to generate</h3>
      <template v-if="error">
        <h3>Very sorry but something went wrong</h3>
        <pre><code>{{ error }}</code></pre>
      </template>
      <button
        v-bind:class="loading ? 'generate loading' : 'generate'"
        v-on:click="handleGenerateZip()"
      >{{ loading ? 'Generating Zip...' : 'Generate Zip' }}</button>
    </div>
  </div>
</template>

<script>
const JSZip = require("jszip");
const saveAs = require("file-saver");
const dayjs = require("dayjs");

export default {
  data: function() {
    return {
      files: [],
      loading: false,
      error: false,
      complete: false
    };
  },
  computed: {
    totalSelectedFilesSize() {
      return this.files
        .map(file => file.size)
        .reduce((accumulator, value) => accumulator + value);
    }
  },
  methods: {
    handleFileSelection() {
      Array.from(this.$refs.files.files).forEach(file => {
        this.files.push(file);
      });
    },
    removeFile(i) {
      this.files.splice(i, 1);
    },
    filesize(file, decimals) {
      if (file.size === 0) return "0 Bytes";
      const k = 1024;
      const dm = decimals < 0 ? 0 : decimals;
      const sizes = ["Bytes", "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"];
      const i = Math.floor(Math.log(file.size) / Math.log(k));
      return (
        parseFloat((file.size / Math.pow(k, i)).toFixed(dm)) + " " + sizes[i]
      );
    },
    clearFiles() {
      this.files = [];
    },
    async handleGenerateZip() {
      if (this.loading) return;
      this.error = false;
      this.loading = true;
      try {
        let zip = new JSZip();
        for (let i = 0; i < this.files.length; i++) {
          const file = this.files[i];
          zip.file(file.name, file, { base64: true });
        }
        const content = await zip.generateAsync({ type: "blob" });
        saveAs(content, `files-${dayjs().format("YYYY-MM-DD-HH-mm-ss")}.zip`);
        this.clearFiles();
        this.loading = false;
        this.complete = true;
      } catch (error) {
        this.error = error;
        this.loading = false;
        this.complete = false;
      }
    }
  }
};
</script>

<style>
html,
body {
  margin: 0;
  padding: 0;
  height: 100%;
}
</style>

<style scoped lang="scss">
#app {
  background: #e0e0e0;
  background: radial-gradient(circle at bottom left, #d8d8d8, #e0e0e0);
  min-height: 100%;
  text-align: center;

  * {
    color: #393939;
    font-family: Avenir, Helvetica, Arial, sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
  }
}

h1 {
  font-size: 3em;
  margin: 0 25px;
  padding-top: 1em;
  text-shadow: 2px 3px #cfcfcf;

  @media (min-width: 1025px) {
    font-size: 4em;
  }
}

h3 {
  margin: 0 25px;
}

button.generate {
  background: #ddd;
  border: 1px solid #aaa;
  border-radius: 6px;
  cursor: pointer;
  display: inline-block;
  font-size: 1.5em;
  margin: 1em;
  outline: 0;
  padding: 0.5em 1em;

  &:hover {
    background: #ccc;
  }
  &:active {
    background: #bbb;
  }
  &.loading {
    cursor: not-allowed;
  }
}

label.upload {
  @extend button.generate;

  &.loading {
    cursor: not-allowed;
    pointer-events: none;
  }

  input[type="file"] {
    position: absolute;
    top: -1000px;
  }
}

.files {
  margin: auto;
  width: 90%;

  @media (min-width: 1025px) {
    width: 35%;
  }

  .file {
    border: 1px solid #cfcfcf;
    border-radius: 4px;
    margin-bottom: 0.5em;
    overflow: hidden;
    padding: 0.5em;

    span.name {
      float: left;
    }

    button {
      background: transparent;
      border: 0;
      cursor: pointer;
      float: right;
      outline: 0;
      padding: 2px 5px;
    }
  }
}
</style>
