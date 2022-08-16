<template>
  <div class="openvpn">
    <a-table :columns="columns" :data-source="allInstances" rowKey=".index">
      <span slot=".name" slot-scope="text, record">
        <template v-if="record.type === 'server'"> {{ text }}_server </template>
        <template v-else> {{ text }}_client </template></span
      >
      <span slot="status" slot-scope="text, record">
        <a-tag :color="record.enable === '0' ? 'volcano' : 'green'">
          <span v-if="record.enable === '1'">Connected</span>
          <span v-if="record.enable === '0'">Disabled</span>
        </a-tag>
      </span>
      <span slot="switch" slot-scope="text, record">
        <a-switch :checked="record.enable === '1'" @change="switchClick(record['.name'], record.enable)" />
      </span>
      <span slot="action" slot-scope="text, record">
        <a-button @click="openModal(record)">Edit </a-button>
        <a-divider type="vertical" />
        <a-popconfirm title="Delete this configuration?" ok-text="Yes" cancel-text="No" @confirm="removeInstance(record)">
          <a-button type="danger">Delete</a-button>
        </a-popconfirm>
      </span>
    </a-table>
    <a-divider />
    <a-form layout="inline" style="margin-right: 40px; float: right" @submit="addInstance()">
      <a-form-item label="Instance Name" :validate-status="createIsDisabled === false ? 'success' : 'error'" :help="createIsDisabled === false ? '' : `Names can't be repeated`" required>
        <a-input v-model="newInstanceName" @change="checkInstnaceName()" required placeholder="Input new instance name" :maxLength="15" />
      </a-form-item>
      <a-form-item label="Role" required>
        <a-select v-model="newInstanceRole" placeholder="Select Role" style="width: 120px" required>
          <a-select-option value="client"> Client </a-select-option>
          <a-select-option value="server"> Server </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit" :disabled="createIsDisabled"> <a-icon type="plus-circle" />Create </a-button>
      </a-form-item>
    </a-form>

    <configuration :visible="editModal" @closeModal="editModal = false" :instanceName="selectedInstanceName" />
  </div>
</template>

<script>
/* eslint-disable */
/* eslint space-before-function-paren: ["error", "never"] */
/* eslint dot-notation: ["error", { "allowPattern": "^[a-z]+(_[a-z]+)+$" }] */
import Configuration from './components/configuration.vue'

const columns = [
  {
    title: 'Name',
    dataIndex: '_name',
    key: '_name',
    slots: { title: '_name' },
    scopedSlots: { customRender: '_name' }
  },
  {
    title: 'Role',
    dataIndex: 'type',
    key: 'role'
  },
  {
    title: 'Status',
    key: 'status',
    dataIndex: 'status',
    scopedSlots: { customRender: 'status' }
  },
  {
    title: 'Switch',
    dataIndex: 'switch',
    key: 'switch',
    scopedSlots: { customRender: 'switch' }
  },
  {
    title: 'Action',
    key: 'action',
    scopedSlots: { customRender: 'action' }
  }
]

export default {
  components: {
    Configuration
  },
  data() {
    return {
      columns,
      editModal: false,
      newInstanceRole: '',
      newInstanceName: '',
      allInstances: [],
      selectedInstanceName: '',
      createIsDisabled: false,
      serverInAFrom: true,
      newAdded: false
    }
  },
  methods: {
    checkInstnaceName() {
      // Checks if name already exists
      let check = 0
      for (let i = 0; i < this.allInstances.length; i++) {
        if (this.newInstanceName === this.allInstances[i]['_name']) {
          check++
        }
      }
      check >= 1 ? (this.createIsDisabled = true) : (this.createIsDisabled = false)
    },
    switchClick(name, enable) {
      // Toogles Enable Button While on main page
      if (enable === '1') {
        enable = '0'
      } else enable = '1'

      this.$uci.set('openvpn', name, 'enable', enable)
      this.saveUci()
    },
    openModal(instance) {
      // Opens Modal and saves that instance before value
      this.selectedInstanceName = instance['.name']

      this.editModal = true
    },

    addInstance() {
      if (this.newInstanceName.length > 15) return this.$message.error('Instance name is too long!')
      if (this.newInstanceRole === 'server' && !this.serverInAFrom) return this.$message.error('Server is already created')
      const sid = this.$uci.add('openvpn', 'openvpn', this.newInstanceName)

      this.$uci.set('openvpn', sid, 'keepalive', '10 120')
      this.$uci.set('openvpn', sid, '_name', this.newInstanceName)
      this.$uci.set('openvpn', sid, 'data_ciphers', ['BF-CBC'])
      this.$uci.set('openvpn', sid, 'persist_key', 1)
      this.$uci.set('openvpn', sid, 'port', 1194)
      this.$uci.set('openvpn', sid, 'tun', 1)
      this.$uci.set('openvpn', sid, 'verb', 5)
      this.$uci.set('openvpn', sid, 'type', this.newInstanceRole)
      this.$uci.set('openvpn', sid, 'proto', 'udp')
      this.$uci.set('openvpn', sid, 'cipher', 'BF-CBC')
      this.$uci.set('openvpn', sid, '_auth', 'skey')
      this.$uci.set('openvpn', sid, 'enable', 0)

      if (this.newInstanceRole === 'client') {
        this.$uci.set('openvpn', sid, 'resolv_retry', 'infinite')
        this.$uci.set('openvpn', sid, 'nobind', 1)
        this.$uci.set('openvpn', sid, 'dev', 'tun_c_' + this.newInstanceName)
        this.$uci.set('openvpn', sid, 'status', '/tmp/openvpn-status_' + this.newInstanceName + '.log')
      } else {
        this.$uci.set('openvpn', sid, 'dev', 'tun_s_' + this.newInstanceName)
      }
      this.saveUci()

      this.$message.success('Configuration added')
      this.newInstanceName = ''
      this.newInstanceRole = 'client'
      this.newAdded = true
    },
    removeInstance(instance) {
      // Removes instace
      this.$rpc
        .call('openvpnlua', 'removeInstance', {
          name: instance['_name'],
          secret: instance.secret,
          ca: instance.ca,
          key: instance.key,
          cert: instance.cert,
          dh: instance.dh
        })
        .then((r) => {
          if (r.status === 'ok') {
            this.$message.success(r.message)
          }
        })
      this.$uci.del('openvpn', instance['.name'])
      this.saveUci()
    },
    async loadInstances() {
      // Loads Instances and also adds other data, that's importnat for  program to work
      await this.$uci.load('openvpn')
      let count = 0
      this.allInstances = this.$uci.sections('openvpn', 'openvpn')

      this.allInstances.forEach((object) => {
        object.type === 'server' ? count++ : ''
      })
      if (count >= 1) {
        this.serverInAFrom = false
      } else this.serverInAFrom = true
      if (this.newAdded) {
        this.openModal(this.allInstances[this.allInstances.length - 1])
        this.newAdded = false
      }
    },
    saveUci() {
      this.$uci.save().then(() => {
        this.$uci.apply().then(() => {
          this.loadInstances()
        })
      })
    }
  },
  watch: {
    editModal() {
      this.loadInstances()
    }
  },
  created() {
    this.loadInstances()
  }
}
</script>
