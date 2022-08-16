<template>
  <div class="insinstance-modal">
    <a-modal v-if="visible" :visible="visible" @cancel="handleCancel()">
      <vuci-form uci-config="openvpn" key=".index" @applied="handleOk()">
        <vuci-named-section class="insinstance-modal-form" :name="instanceName" v-slot="{ s }" :card="false">
          <template v-if="s.type === 'server'">
            <h3>{{ s['.name'] }} Server Configuaration</h3>
          </template>
          <template v-if="s.type === 'client'">
            <h3>{{ s['.name'] }} Client Configuaration</h3>
          </template>
          <a-checkbox :checked="advancedCheck" @change="advancedCheck = !advancedCheck"> Advanced </a-checkbox>
          <a-divider />
          <vuci-form-item-switch label="Enable/Disable" name="enable" :uci-section="s" required />
          <vuci-form-item-select label="Authentication Type" v-model="s['_auth']" name="_auth" :uci-section="s" :options="auth" required />
          <vuci-form-item-input label="Remote host/IP address" :uci-section="s" name="remote" depend="_auth === 'skey'" />
          <vuci-form-item-input label="Local tunnel endpoint IP" :uci-section="s" name="local_ip" depend="_auth === 'skey'" rules="ip4addr" />
          <vuci-form-item-input label="Remote tunnel endpoint IP" :uci-section="s" name="remote_ip" depend="_auth === 'skey'" rules="ip4addr" />
          <vuci-form-item-input
            label="Remote network IP address"
            :uci-section="s"
            name="network_ip"
            depend="_auth === 'skey'"
            :rules="'ip4addr'"
            :help="instance.network_ip === router_lan ? 'remote IP same as roter IP' : ''"
            @change="instance.network_ip = $event.model"
          />
          <vuci-form-item-input label="Remote network netmask" :uci-section="s" name="network_mask" depend="_auth === 'skey'" rules="netmask4" />
          <vuci-form-item :uci-section="s" name="" label="Static key upload" depend="_auth === 'skey'">
            <a-upload
              @change="onFileUpload($event, 'secret')"
              action="/upload"
              :data="{
                path: '/etc/vuci-upload/openvpn/' + s['.name'] + '.secretstatic.key'
              }"
              ><a-button :disabled="disableUpload" type="primary" icon="upload" @click="tempFileLocation = '/etc/vuci-upload/openvpn/' + s['.name'] + '.secretstatic.key'">Select File</a-button>
            </a-upload>
            <div :uci-section="s">
              {{ s.secret ? s.secret.split('/').slice(4, 5).join('/') : '' }}
            </div>
          </vuci-form-item>
          <div v-if="s.type === 'client'">
            <vuci-form-item-input label="Remote host/IP address" :uci-section="s" name="remote" depend="_auth === 'tls'" />
            <vuci-form-item-input label="Remote network IP address" :uci-section="s" name="network_ip" depend="_auth === 'tls'" rules="ip4addr" />
            <vuci-form-item-input label="Remote network netmask" :uci-section="s" name="network_mask" depend="_auth === 'tls'" rules="ip4addr" />
          </div>
          <div v-if="s.type === 'server'">
            <vuci-form-item-input label="Virtual network IP address" :uci-section="s" name="server_ip" depend="_auth === 'tls'" rules="ip4addr" />
            <vuci-form-item-input label="Virtual network netmask" :uci-section="s" name="server_netmask" depend="_auth === 'tls'" rules="ip4addr" />
          </div>
          <vuci-form-item :uci-section="s" name="" label="Authority certificate upload" depend="_auth === 'tls'">
            <a-upload
              @change="onFileUpload($event, 'ca')"
              action="/upload"
              :data="{
                path: '/etc/vuci-upload/openvpn/' + s['.name'] + '.auth_cert'
              }"
              ><a-button :disabled="disableUpload" type="primary" icon="upload" @click="tempFileLocation = '/etc/vuci-upload/openvpn/' + s['.name'] + '.auth_cert'">Select File</a-button>
            </a-upload>
            <div :uci-section="s">
              {{ s.ca ? s.ca.split('/').slice(4, 5).join('/') : '' }}
            </div>
          </vuci-form-item>

          <vuci-form-item :uci-section="s" name="" :label="s.type === 'server' ? 'Server certificate upload' : 'Client certificate upload'" depend="_auth === 'tls'">
            <a-upload
              @change="onFileUpload($event, 'cert')"
              action="/upload"
              :data="{
                path: '/etc/vuci-upload/openvpn/' + s['.name'] + '.auth'
              }"
              ><a-button :disabled="disableUpload" type="primary" icon="upload" @click="tempFileLocation = '/etc/vuci-upload/openvpn/' + s['.name'] + '.auth'">Select File</a-button>
            </a-upload>
            <div :uci-section="s">
              {{ s.cert ? s.cert.split('/').slice(4, 5).join('/') : '' }}
            </div>
          </vuci-form-item>
          <vuci-form-item :uci-section="s" name="key" :label="s.type === 'server' ? 'Server key upload' : 'Client key upload'" depend="_auth === 'tls'">
            <a-upload
              @change="onFileUpload($event, 'key')"
              action="/upload"
              :data="{
                path: '/etc/vuci-upload/openvpn/' + s['.name'] + '.key'
              }"
              ><a-button :disabled="disableUpload" type="primary" icon="upload" @click="s.key = '/etc/vuci-upload/openvpn/' + s['.name'] + '.key'">Select File</a-button>
            </a-upload>
            <div :uci-section="s">
              {{ s.key ? s.key.split('/').slice(4, 5).join('/') : '' }}
            </div>
          </vuci-form-item>
          <vuci-form-item :uci-section="s" name="dh" label="Diffie Hellman param upload" v-if="s.type === 'server'" depend="_auth === 'tls'">
            <a-upload
              @change="onFileUpload($event, 'dh')"
              action="/upload"
              :data="{
                path: '/etc/vuci-upload/openvpn/' + s['.name'] + '.dh'
              }"
              ><a-button :disabled="disableUpload" type="primary" icon="upload" @click="tempFileLocation = '/etc/vuci-upload/openvpn/' + s['.name'] + '.dh'">Select File</a-button>
            </a-upload>
            <div :uci-section="s">
              {{ s.dh ? s.dh.split('/').slice(4, 5).join('/') : '' }}
            </div>
          </vuci-form-item>
          <div v-show="advancedCheck">
            <hr />
            <h2>Advanced</h2>
            <vuci-form-item-input label="Keep alive" :uci-section="s" name="keepalive" />
            <vuci-form-item-input label="Port" :uci-section="s" name="port" />
            <vuci-form-item-checkbox label="Persist Key" :uci-section="s" name="persist_key" />
            <vuci-form-item-checkbox label="Persist Tun" :uci-section="s" name="tun" />
            <vuci-form-item-select label="Protocol" :uci-section="s" name="proto" :options="proto" />
            <vuci-form-item-list label="Data ciphers" :uci-section="s" name="data_ciphers" />
            <vuci-form-item-select label="Scipher" :uci-section="s" name="cipher" :options="encryption" />
            <div v-if="s.type === 'server'">
              <vuci-form-item-list label="Push Option" :uci-section="s" name="push" />
            </div>
          </div>
        </vuci-named-section>
      </vuci-form>
      <template #footer></template>
    </a-modal>
  </div>
</template>
<script>
/* eslint-disable */

export default {
  name: 'Configuaration',
  props: {
    visible: Boolean,
    instanceName: String
  },
  data() {
    return {
      tempFileLocation: '',
      disableUpload: false,
      router_lan: '',
      auth: [
        ['skey', 'Static'],
        ['tls', 'TLS']
      ],
      proto: [
        ['udp', 'UDP'],
        ['tcp', 'TCP'],
        ['udp6', 'UDP6'],
        ['tcp6', 'TCP6']
      ],
      encryption: [
        ['skey', 'Static'],
        ['tls', 'TLS']
      ],
      instance: {
        network_ip: ''
      },
      advancedCheck: false
    }
  },
  methods: {
    handleOk() {
      // If Edited function updates the values
      if (this.instance.network_ip === this.router_lan) return this.$message.error('Please provide diffrent network IP')
      this.deleteOldValue() //First Deletes old data and files

      this.advancedCheck = false
      this.$emit('closeModal')
    },
    handleCancel() {
      this.advancedCheck = false
      this.$emit('closeModal')
    },
    setEncriptionOptions() {
      this.encryption = this.$uci.get('openvpn', this.instanceName, 'data_ciphers')
    },

    deleteOldValue() {
      this.$uci.load('openvpn')
      const authType = this.$uci.get('openvpn', this.instanceName, '_auth')
      const instanceType = this.$uci.get('openvpn', this.instanceName, 'type')
      console.log(authType)

      this.$rpc.call('openvpnlua', 'deleteFiles', {
        auth: authType,
        name: this.instanceName
      })
      switch (true) {
        case authType === 'skey':
          this.$uci.set('openvpn', this.instanceName, 'ca', '')
          this.$uci.set('openvpn', this.instanceName, 'cert', '')
          this.$uci.set('openvpn', this.instanceName, 'key', '')
          if (instanceType === 'server') {
            this.$uci.set('openvpn', this.instanceName, 'server_ip', '')
            this.$uci.set('openvpn', this.instanceName, 'server_netmask', '')
            this.$uci.set('openvpn', this.instanceName, 'dh', '')
          }
          break
        case authType === 'tls':
          this.$uci.set('openvpn', this.instanceName, 'local_ip', '')
          this.$uci.set('openvpn', this.instanceName, 'remote_ip', '')
          this.$uci.set('openvpn', this.instanceName, 'secret', '')
          if (instanceType === 'server') {
            this.$uci.set('openvpn', this.instanceName, 'network_ip', '')
            this.$uci.set('openvpn', this.instanceName, 'network_mask', '')
          }
          break
      }
      this.$uci.save().then(() => {
        this.$uci.apply()
      })
    },

    onFileUpload(info, instanceOption) {
      console.log(info)
      if (this.onUpload(info)) {
        this.$uci.set('openvpn', this.instanceName, instanceOption, this.tempFileLocation)
        this.tempFileLocation = ''
      }
    },
    onUpload(info) {
      const file = info.file
      const status = file.status
      if (status === 'uploading') {
        this.disableUpload = true
        return false
      }
      if (status === 'removed') {
        this.disableUpload = false
        this.tempFileLocation = ''
        return false
      }
      info.fileList.length = 0
      if (status !== 'done') {
        this.$message.error(`upload '${file.name}' failed.`)
        this.disableUpload = false
        return false
      } else {
        this.$message.success(`file '${file.name}' uploaded`)
        this.disableUpload = false
        return true
      }
    },
    //------------------------------------------------------------------------------------------
    checkRouterLan() {
      this.$network.load().then(() => {
        const iface = this.$network.getInterface('lan')
        this.router_lan = iface.status['ipv4-address'][0].address
      })
    }
  },
  watch: {
    advancedCheck() {
      this.setEncriptionOptions()
    }
  },
  created() {
    this.checkRouterLan()
  }
}
</script>
<style>
.insinstance-modal-form > * > .ant-form-item-label,
.insinstance-modal-form > div > * > .ant-form-item-label,
.insinstance-modal-form > div > * > * > .ant-form-item-label {
  width: 40%;
  text-align: left;
}
</style>
