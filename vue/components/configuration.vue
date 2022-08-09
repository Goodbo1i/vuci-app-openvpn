<template>
  <div class="configuration">
    <a-modal :visible="visible" @cancel="handleCancel()">
      <a-form
        id="components-form-demo-validate-other"
        :label-col="{ span: 10 }"
        :wrapper-col="{ span: 14 }"
      >
        <template v-if="type === 'server'">
          <h3>{{ name }} Server Configuaration</h3>
        </template>
        <template v-if="type === 'client'">
          <h3>{{ name }} Client Configuaration</h3>
        </template>
        <a-divider />
        <!-- surasyti skirtingus configuracijos fieldus -->
        <a-form-item label="Enable/Disable" name="enable" required>
          <a-switch
            name="enable"
            @change="toggleSwitch(selectedInstance.enable)"
            :checked="selectedInstance.enable === '1'"
          />
        </a-form-item>
        <a-form-item label="Authentication Type" required>
          <a-select v-model="selectedInstance['_auth']">
            <a-select-option value="skey" default>Static Key</a-select-option>
            <a-select-option value="tls">TLS</a-select-option>
          </a-select>
        </a-form-item>

        <template v-if="selectedInstance['_auth'] === 'skey'">
          <a-form-item label="Remote host/IP address" v-if="type === 'client'">
            <a-input v-model="selectedInstance.remote" />
          </a-form-item>
          <a-form-item
            label="Local tunnel endpoint IP"
            :validate-status="validations.localIpError"
            :help="
              validations.localIpError === 'success'
                ? ''
                : 'Please input a valid IP'
            "
          >
            <a-input
              v-model="selectedInstance.local_ip"
              @blur="validateIp(selectedInstance.local_ip, 'local_ip')"
            />
          </a-form-item>
          <a-form-item
            label="Remote tunnel endpoint IP"
            :validate-status="validations.remoteIpError"
            :help="
              validations.remoteIpError === 'success'
                ? ''
                : 'Please input a valid IP'
            "
          >
            <a-input
              v-model="selectedInstance.remote_ip"
              @blur="validateIp(selectedInstance.remote_ip, 'remote_ip')"
            />
          </a-form-item>
          <a-form-item
            label="Remote network IP address"
            :validate-status="validations.networkIpError"
            :help="
              validations.networkIpError === 'success'
                ? ''
                : 'Please input a valid IP and not LAN IP'
            "
          >
            <a-input
              v-model="selectedInstance.network_ip"
              @blur="validateIp(selectedInstance.network_ip, 'network_ip')"
            />
          </a-form-item>
          <a-form-item
            label="Remote network netmask"
            :validate-status="validations.networkMaskError"
            :help="
              validations.networkMaskError === 'success'
                ? ''
                : 'Please input a valid netmask'
            "
          >
            <a-input
              v-model="selectedInstance.network_mask"
              @blur="
                validateMask(selectedInstance.network_mask, 'network_mask')
              "
            />
          </a-form-item>
          <a-form-item label="Static key upload">
            <a-upload
              @change="onUploadServerStatic"
              action="/upload"
              :data="{
                path:
                  '/etc/vuci-upload/openvpn/' +
                  selectedInstance['.name'] +
                  '.secretstatic.key'
              }"
            >
              <a-button
                :disabled="disableUpload"
                type="primary"
                icon="upload"
                @click="
                  tempFileLocation =
                    '/etc/vuci-upload/openvpn/' +
                    selectedInstance['.name'] +
                    '.secretstatic.key'
                "
                >Select File</a-button
              ><span v-if="selectedInstance.secret != ''">{{
                selectedInstance.secret.split('/').slice(4, 5).join('/')
              }}</span>
              <span v-if="selectedInstance.secret === ''"> Not uploaded </span>
            </a-upload>
          </a-form-item>
        </template>
        <template v-if="selectedInstance['_auth'] === 'tls'">
          <a-form-item
            label="Virtual network IP address"
            :validate-status="validations.virtualIpError"
            :help="
              validations.virtualIpError === 'success'
                ? ''
                : 'Please input a valid IP'
            "
            v-if="type === 'server'"
          >
            <a-input
              v-model="selectedInstance.server_ip"
              @blur="validateIp(selectedInstance.server_ip, 'server_ip')"
            />
          </a-form-item>
          <a-form-item
            label="Virtual network netmask"
            :validate-status="validations.virtualNetmaskError"
            :help="
              validations.virtualNetmaskError === 'success'
                ? ''
                : 'Please input a valid netmask'
            "
            v-if="type === 'server'"
          >
            <a-input
              v-model="selectedInstance.server_netmask"
              @blur="
                validateMask(selectedInstance.server_netmask, 'server_netmask')
              "
            />
          </a-form-item>
          <a-form-item label="Remote host/IP address" v-if="type === 'client'">
            <a-input v-model="selectedInstance.remote" />
          </a-form-item>

          <a-form-item
            label="Remote network IP address"
            :validate-status="validations.networkIpError"
            :help="
              validations.networkIpError === 'success'
                ? ''
                : 'Please input a valid IP and not LAN IP'
            "
            v-if="type === 'client'"
          >
            <a-input
              v-model="selectedInstance.network_ip"
              @blur="validateIp(selectedInstance.network_ip, 'network_ip')"
            />
          </a-form-item>
          <a-form-item
            label="Remote network netmask"
            :validate-status="validations.networkMaskError"
            :help="
              validations.networkMaskError === 'success'
                ? ''
                : 'Please input a valid netmask'
            "
            v-if="type === 'client'"
          >
            <a-input
              v-model="selectedInstance.network_mask"
              @blur="
                validateMask(selectedInstance.network_mask, 'network_mask')
              "
            />
          </a-form-item>
          <a-form-item label="Authority certificate upload">
            <a-upload
              v-model="selectedInstance.ca"
              @change="onUploadCertAuth"
              action="/upload"
              :data="{
                path:
                  '/etc/vuci-upload/openvpn/' +
                  selectedInstance['.name'] +
                  '.auth_cert'
              }"
            >
              <a-button
                :disabled="disableUpload"
                type="primary"
                icon="upload"
                @click="
                  tempFileLocation =
                    '/etc/vuci-upload/openvpn/' +
                    selectedInstance['.name'] +
                    '.auth_cert'
                "
                >Select File</a-button
              >
              <span v-if="selectedInstance.ca != ''">{{
                selectedInstance.ca.split('/').slice(4, 5).join('/')
              }}</span>
              <span v-if="selectedInstance.ca === ''"> Not uploaded </span>
            </a-upload>
          </a-form-item>
          <a-form-item
            :label="
              type === 'server'
                ? 'Server certificate upload'
                : 'Client certificate upload'
            "
          >
            <a-upload
              v-model="selectedInstance.cert"
              @change="onUploadCert"
              action="/upload"
              :data="{
                path:
                  '/etc/vuci-upload/openvpn/' +
                  selectedInstance['.name'] +
                  '.auth'
              }"
            >
              <a-button
                :disabled="disableUpload"
                type="primary"
                icon="upload"
                @click="
                  tempFileLocation =
                    '/etc/vuci-upload/openvpn/' +
                    selectedInstance['.name'] +
                    '.auth'
                "
                >Select File</a-button
              >
              <span v-if="selectedInstance.cert != ''">{{
                selectedInstance.cert.split('/').slice(4, 5).join('/')
              }}</span>
              <span v-if="selectedInstance.cert === ''"> Not uploaded </span>
            </a-upload>
          </a-form-item>
          <a-form-item
            :label="
              type === 'server' ? 'Server key upload' : 'Client key upload'
            "
          >
            <a-upload
              v-model="selectedInstance.key"
              @change="onUploadKey"
              action="/upload"
              :data="{
                path:
                  '/etc/vuci-upload/openvpn/' +
                  selectedInstance['.name'] +
                  '.key'
              }"
            >
              <a-button
                :disabled="disableUpload"
                type="primary"
                icon="upload"
                @click="
                  tempFileLocation =
                    '/etc/vuci-upload/openvpn/' +
                    selectedInstance['.name'] +
                    '.key'
                "
                >Select File</a-button
              ><span v-if="selectedInstance.key != ''">{{
                selectedInstance.key.split('/').slice(4, 5).join('/')
              }}</span>
              <span v-if="selectedInstance.key === ''"> Not uploaded </span>
            </a-upload>
          </a-form-item>
          <a-form-item
            label="Diffie Hellman params upload"
            v-if="type === 'server'"
          >
            <a-upload
              v-model="selectedInstance.dh"
              @change="onUploadDH"
              action="/upload"
              :data="{
                path:
                  '/etc/vuci-upload/openvpn/' +
                  selectedInstance['.name'] +
                  '.dh'
              }"
            >
              <a-button
                :disabled="disableUpload"
                type="primary"
                icon="upload"
                @click="
                  tempFileLocation =
                    '/etc/vuci-upload/openvpn/' +
                    selectedInstance['.name'] +
                    '.dh'
                "
                >Select File</a-button
              ><span v-if="selectedInstance.dh != ''">{{
                selectedInstance.dh.split('/').slice(4, 5).join('/')
              }}</span>
              <span v-if="selectedInstance.dh === ''"> Not uploaded </span>
            </a-upload>
          </a-form-item>
        </template>
      </a-form>
      <template slot="footer">
        <a-button key="cancel" @click="handleCancel()"> Cancel </a-button>
        <a-button
          key="submit"
          type="primary"
          @click="handleOk()"
          :disabled="saveIsDisabled"
        >
          Save
        </a-button>
      </template>
    </a-modal>
  </div>
</template>
<script>
/* eslint-disable */

export default {
  name: 'Configuaration',
  props: {
    type: String,
    name: String,
    visible: Boolean,
    selectedInstance: undefined,
    validation: undefined
  },
  data() {
    return {
      tempFileLocation: '',
      disableUpload: false,
      validations: {
        remoteIpError: 'success',
        localIpError: 'success',
        networkIpError: 'success',
        networkMaskError: 'success',
        virtualNetmaskError: 'success',
        virtualIpError: 'success'
      },
      router_lan: '',
      saveIsDisabled: false
    }
  },
  methods: {
    validateIp(value, name) {
      // Validates IP and sends out error message if it's invalid
      let isError = this.ip4addr(value)
      if (name === 'remote_ip' && !isError && value != '') {
        this.validations.remoteIpError = 'error'
      } else if (name === 'remote_ip' && isError) {
        this.validations.remoteIpError = 'success'
      }
      if (name === 'local_ip' && !isError && value != '') {
        this.validations.localIpError = 'error'
      } else if ((name === 'local_ip' && isError) || value === '') {
        this.validations.localIpError = 'success'
      }
      if (
        (name === 'network_ip' && !isError) ||
        (value === this.router_lan && value != '')
      ) {
        this.validations.networkIpError = 'error'
      } else if (
        (name === 'network_ip' && isError) ||
        value === '' ||
        value != this.router_lan
      ) {
        this.validations.networkIpError = 'success'
      }

      if (name === 'server_ip' && !isError && value != '') {
        this.validations.virtualIpError = 'error'
      } else if ((name === 'server_ip' && isError) || value === '') {
        this.validations.virtualIpError = 'success'
      }
      this.checkValidations()
    },
    validateMask(value, name) {
      // Validates Mask and sends out error message if it's invalid
      let isError = this.ip4addr(value)

      if (name === 'network_mask' && !isError && value != '') {
        this.validations.networkMaskError = 'error'
      } else if ((name === 'network_mask' && isError) || value === '') {
        this.validations.networkMaskError = 'success'
      }

      if (name === 'server_netmask' && !isError && value != '') {
        this.validations.virtualNetmaskError = 'error'
      } else if ((name === 'server_netmask' && isError) || value === '') {
        this.validations.virtualNetmaskError = 'success'
      }
      this.checkValidations()
    },
    //checkMask(value) {
    //  if (
    //    /^((128|192|224|240|248|252|254)\.0\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0\.0)|(255\.(((0|128|192|224|240|248|252|254)\.0)|255\.(0|128|192|224|240|248|252|254|255)))))$/.test(
    //      value
    //    )
    //  )
    //    return false
    //  else return true
    //},
    checkValidations() {
      // Check If all validations are OK, only then save button is enabled
      let count = 0
      for (let i = 0; i < Object.keys(this.validations).length; i++) {
        let insideValidations = Object.keys(this.validations)[i]

        if (this.validations[insideValidations] != 'success') {
          count++
        }
      }
      count === 0 ? (this.saveIsDisabled = false) : (this.saveIsDisabled = true)
    },
    handleCancel() {
      for (let i = 0; i < Object.keys(this.validations).length; i++) {
        let resetValidations = Object.keys(this.validations)[i]
        this.validations[resetValidations] = 'success'
      }
      // console.log(Object.keys(this.validations)[1])
      // console.log(Object.keys(this.validations))
      // console.log(Object.keys(this.validations).length)
      this.$emit('changeInstanceBack')
      this.$emit('closeModal')
    },
    toggleSwitch(switchValue) {
      if (switchValue === '1') {
        this.selectedInstance.enable = '0'
      } else this.selectedInstance.enable = '1'
    },
    ip4addr(value) {
      return !!this.parseIPv4(value)
    },
    parseIPv4(str) {
      if (
        (typeof str !== 'string' && !(str instanceof String)) ||
        !str.match(/^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/)
      ) {
        return undefined
      }
      const num = []
      const parts = str.split(/\./)
      for (let i = 0; i < parts.length; i++) {
        const n = parseInt(parts[i])
        if (isNaN(n) || n > 255) {
          return undefined
        }
        num.push(n)
      }
      return num
    },

    deleteOldValue() {
      this.$rpc
        .call('openvpnlua', 'deleteFiles', {
          auth: this.selectedInstance['_auth'],
          secret: this.selectedInstance.secret,
          ca: this.selectedInstance.ca,
          key: this.selectedInstance.key,
          cert: this.selectedInstance.cert,
          dh: this.selectedInstance.dh
        })
        .then((r) => {
          this.$message.success(r.message)
        })

      switch (true) {
        case this.selectedInstance.type === 'client' &&
          this.selectedInstance['_auth'] === 'skey':
          this.selectedInstance.ca = ''
          this.selectedInstance.cert = ''
          this.selectedInstance.key = ''
          break
        case this.selectedInstance.type === 'client' &&
          this.selectedInstance['_auth'] === 'tls':
          this.selectedInstance.local_ip = ''
          this.selectedInstance.remote_ip = ''
          this.selectedInstance.secret = ''
          break
        case this.selectedInstance.type === 'server' &&
          this.selectedInstance['_auth'] === 'client':
          this.selectedInstance.server_ip = ''
          this.selectedInstance.server_netmask = ''
          this.selectedInstance.ca = ''
          this.selectedInstance.cert = ''
          this.selectedInstance.key = ''
          this.selectedInstance.dh = ''
          break
        case this.selectedInstance.type === 'server' &&
          this.selectedInstance['_auth'] === 'tls':
          this.selectedInstance.local_ip = ''
          this.selectedInstance.remote_ip = ''
          this.selectedInstance.network_ip = ''
          this.selectedInstance.network_mask = ''
          this.selectedInstance.secret = ''
          break
      }
    },
    handleOk() {
      // If Edited function updates the values
      this.deleteOldValue() //First Deletes old data and files

      this.$rpc // Continous to update data values
        .call('openvpnlua', 'editInstance', {
          name: this.selectedInstance['_name'],
          enable: this.selectedInstance.enable,
          auth: this.selectedInstance['_auth'],
          local_ip: this.selectedInstance.local_ip,
          server_ip: this.selectedInstance.server_ip,
          server_netmask: this.selectedInstance.server_netmask,
          remote: this.selectedInstance.remote,
          remote_ip: this.selectedInstance.remote_ip,
          network_ip: this.selectedInstance.network_ip,
          network_mask: this.selectedInstance.network_mask,
          secret: this.selectedInstance.secret,
          ca: this.selectedInstance.ca,
          key: this.selectedInstance.key,
          cert: this.selectedInstance.cert,
          dh: this.selectedInstance.dh,
          tls_auth: 'none'
        })
        .then((r) => {
          if (r.status === 'ok') {
            this.$message.success(r.message)
            this.$emit('closeModal')
          }
        })
    },
    //Diffrent Upload methods--------------------------------------------------------------------
    onUploadServerStatic(info) {
      if (this.onUpload(info)) {
        this.selectedInstance.secret = this.tempFileLocation
        this.tempFileLocation = ''
      }
    },
    onUploadCertAuth(info) {
      if (this.onUpload(info)) {
        this.selectedInstance.ca = this.tempFileLocation
        this.tempFileLocation = ''
      }
    },
    onUploadCert(info) {
      if (this.onUpload(info)) {
        this.selectedInstance.cert = this.tempFileLocation
        this.tempFileLocation = ''
      }
    },
    onUploadKey(info) {
      if (this.onUpload(info)) {
        this.selectedInstance.key = this.tempFileLocation
        this.tempFileLocation = ''
      }
    },
    onUploadDH(info) {
      if (this.onUpload(info)) {
        this.selectedInstance.dh = this.tempFileLocation
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
  created() {
    this.checkRouterLan()
  }
}
</script>
<style>
#components-form-demo-validate-other .dropbox {
  height: 180px;
  line-height: 1.5;
}
</style>
