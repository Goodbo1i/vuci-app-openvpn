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
        <a-switch
          :checked="record.enable === '1'"
          @change="switchClick(record['.name'], record.enable)"
        />
      </span>
      <span slot="action" slot-scope="text, record">
        <a-button @click="openModal(record)">Edit </a-button>
        <a-divider type="vertical" />
        <a-popconfirm
          title="Delete this configuration?"
          ok-text="Yes"
          cancel-text="No"
          @confirm="removeInstance(record)"
        >
          <a-button type="danger">Delete</a-button>
        </a-popconfirm>
      </span>
    </a-table>
    <a-divider />
    <a-form
      layout="inline"
      style="margin-right: 40px; float: right"
      @submit="addInstance()"
    >
      <a-form-item
        label="Instance Name"
        :validate-status="createIsDisabled === false ? 'success' : 'error'"
        :help="createIsDisabled === false ? '' : `Names can't be repeated`"
        required
      >
        <a-input
          v-model="newInstanceName"
          @change="checkInstnaceName()"
          required
          placeholder="Input new instance name"
          :maxLength="15"
        />
      </a-form-item>
      <a-form-item label="Role" required>
        <a-select
          v-model="newInstanceRole"
          placeholder="Select Role"
          style="width: 120px"
          required
        >
          <a-select-option value="client"> Client </a-select-option>
          <a-select-option value="server" v-if="serverInAFrom">
            Server
          </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item>
        <a-button
          type="primary"
          html-type="submit"
          :disabled="createIsDisabled"
        >
          <a-icon type="plus-circle" />Create
        </a-button>
      </a-form-item>
    </a-form>

    <configuration
      :type="instanceRole"
      :name="instanceName"
      :visible="editModal"
      @toggleSwitch="
        switchClick(selectedInstance['.name'], selectedInstance.enable)
      "
      @changeInstanceBack="changeInstanceBack()"
      @closeModal="editModal = false"
      :selectedInstance="selectedInstance"
    />
  </div>
</template>

<script>
/* eslint space-before-function-paren: ["error", "never"] */
/* eslint dot-notation: ["error", { "allowPattern": "^[a-z]+(_[a-z]+)+$" }] */
import Configuration from './components/configuration.vue'

const columns = [
  {
    title: 'Name',
    dataIndex: '.name',
    key: '.name',
    slots: { title: 'customTitle' },
    scopedSlots: { customRender: '.name' }
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
      instanceName: '',
      instanceRole: '',
      newInstanceRole: '',
      newInstanceName: '',
      allInstances: [],
      selectedInstance: {},
      beforeEdit: {},
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
        if (this.newInstanceName === this.allInstances[i]['.name']) {
          check++
        }
      }
      check >= 1
        ? (this.createIsDisabled = true)
        : (this.createIsDisabled = false)
    },
    switchClick(name, enable) {
      // Toogles Enable Button While on main page
      if (enable === '1') {
        enable = '0'
      } else enable = '1'
      this.$rpc
        .call('openvpnlua', 'toggleSwitch', { name: name, enable: enable })
        .then((r) => {
          this.loadInstances()
        })
    },
    openModal(instance) {
      // Opens Modal and saves that instance before value
      this.selectedInstance = instance
      Object.assign(this.beforeEdit, this.selectedInstance)

      this.instanceName = instance['.name']
      this.instanceRole = instance.type
      this.editModal = true
    },
    addInstance() {
      // Adds new instance
      this.$rpc
        .call('openvpnlua', 'setInterface', {
          name: this.newInstanceName,
          type: 'openvpn',
          role: this.newInstanceRole
        })
        .then((r) => {
          this.$message.success('Configuration added')
          this.newInstanceName = ''
          this.newInstanceRole = 'client'
          this.newAdded = true
          this.loadInstances()
        })
    },
    loadInstances() {
      // Loads Instances and also adds other data, that's importnat for  program to work
      let count = 0
      this.allInstances = []
      this.$rpc
        .call('openvpnlua', 'getOpenVPNData', {})
        .then((r) => {
          if (r.status === 'ok') {
            for (let i = 0; i < Object.keys(r.data).length; i++) {
              if (!r.data[i].local_ip) {
                r.data[i].local_ip = ''
              }
              if (!r.data[i].remote) {
                r.data[i].remote = ''
              }
              if (!r.data[i].remote_ip) {
                r.data[i].remote_ip = ''
              }
              if (!r.data[i].network_ip) {
                r.data[i].network_ip = ''
              }
              if (!r.data[i].network_mask) {
                r.data[i].network_mask = ''
              }
              if (!r.data[i].secret) {
                r.data[i].secret = ''
              }
              if (!r.data[i].ca) {
                r.data[i].ca = ''
              }
              if (!r.data[i].key) {
                r.data[i].key = ''
              }
              if (!r.data[i].cert) {
                r.data[i].cert = ''
              }
              if (!r.data[i].dh) {
                r.data[i].dh = ''
              }
              if (!r.data[i].server_ip) {
                r.data[i].server_ip = ''
              }
              if (!r.data[i].server_netmask) {
                r.data[i].server_netmask = ''
              }
              r.data[i].status = 'Connected'
              this.allInstances.push(r.data[i])
              if (r.data[i].type === 'server') {
                count++
              }
            }
            if (count >= 1) {
              this.serverInAFrom = false
            } else this.serverInAFrom = true
            if (this.newAdded) {
              this.openModal(this.allInstances[this.allInstances.length - 1])
              this.newAdded = false
            }
          }
        })
        .catch((e) => {
          this.$message.error(e)
        })
    },
    removeInstance(instance) {
      // Removes instace
      this.$rpc
        .call('openvpnlua', 'removeInstance', {
          name: instance['.name'],
          secret: instance.secret,
          ca: instance.ca,
          key: instance.key,
          cert: instance.cert,
          dh: instance.dh
        })
        .then((r) => {
          if (r.status === 'ok') {
            this.$message.success(r.message)
            this.loadInstances()
          }
        })
    },
    changeInstanceBack() {
      // If Modal is canceled then function brings back old data to that instnace
      for (let i = 0; i < this.allInstances.length; i++) {
        if (this.allInstances[i]['.name'] === this.beforeEdit['.name']) {
          Object.assign(this.allInstances[i], this.beforeEdit)
        }
      }
    }
  },

  created() {
    this.loadInstances()
  }
}
</script>
