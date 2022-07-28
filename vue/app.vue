<template>
  <div class="openvpn">
    <a-table :columns="columns" :data-source="data">
      <span slot="customTitle"> Name</span>
      <span slot="status" slot-scope="status">
        <a-tag
          v-for="stat in status"
          :key="stat"
          :color="stat === 'loser' ? 'volcano' : 'green'"
        >
          {{ stat.toUpperCase() }}
        </a-tag>
      </span>
      <span slot="switch" slot-scope="text, record">
        <a-switch :checked="record.switch === '1'" @change="switchClick()" />
      </span>
      <span slot="action" slot-scope="text, record">
        <a-button @click="openModal(record.name, record.role)">Edit </a-button>
        <a-divider type="vertical" />
        <a-popconfirm
          title="Delete this configuration?"
          ok-text="Yes"
          cancel-text="No"
        >
          <a-button type="danger">Delete</a-button>
        </a-popconfirm>
      </span>
    </a-table>
    <a-divider />
    <a-form layout="inline" style="margin-right: 40px; float: right">
      <a-form-item label="Instance Name" required>
        <a-input placeholder="Input new instance name" />
      </a-form-item>
      <a-form-item label="Role" required>
        <a-select placeholder="Select Role" style="width: 120px">
          <a-select-option value="client"> Client </a-select-option>
          <a-select-option value="server"> Server </a-select-option>
        </a-select>
      </a-form-item>
      <a-form-item>
        <a-button type="primary" html-type="submit">
          <a-icon type="plus-circle" />Create
        </a-button>
      </a-form-item>
    </a-form>
    <a-modal v-model="editModal">
      <template>
        <configuration :type="interfaceRole" :name="interfaceName" />
      </template>
    </a-modal>
  </div>
</template>

<script>
/* eslint space-before-function-paren: ["error", "never"] */
import Configuration from './components/configuration.vue'

const columns = [
  {
    dataIndex: 'name',
    key: 'name',
    slots: { title: 'customTitle' },
    scopedSlots: { customRender: 'name' }
  },
  {
    title: 'Role',
    dataIndex: 'role',
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

const data = [
  {
    key: '1',
    name: 'John Brown',
    role: 'client',
    switch: '1',
    status: ['nice', 'developer']
  },
  {
    key: '2',
    name: 'Jim Green',
    role: 'server',
    switch: '1',
    status: ['loser']
  },
  {
    key: '3',
    name: 'Joe Black',
    role: 'client',
    switch: '0',
    status: ['cool', 'teacher']
  }
]
export default {
  components: {
    Configuration
  },
  data() {
    return {
      data,
      columns,
      editModal: false,
      interfaceName: '',
      interfaceRole: ''
    }
  },
  methods: {
    openModal(interfaceName, interfaceRole) {
      this.interfaceName = interfaceName
      this.interfaceRole = interfaceRole
      console.log(interfaceRole)
      this.editModal = true
    }
  }
}
</script>
