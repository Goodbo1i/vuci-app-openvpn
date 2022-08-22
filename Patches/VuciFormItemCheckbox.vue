<template>
  <vuci-form-item-template v-bind="VuciFormItemTemplateProps">
    <a-checkbox v-model="model"/>
  </vuci-form-item-template>
</template>

<script>
/* eslint-disable */

import VuciFormItemMixin from './VuciFormItemMixin'

export default {
  name: 'VuciFormItemCheckbox',
  mixins: [VuciFormItemMixin],
  props: {
    initial: Boolean,
		defaultValue: String,
    trueValue: {
      type: [String, Boolean, Number],
      default: '1'
    },
    falseValue: {
      type: [String, Boolean, Number],
      default: '0'
    }
  },
  computed: {
    dependExprValue() {
      return `${this.model}`
    }
  },
  methods: {
    convertUciValue(value) {
      if (typeof value !== 'boolean') return value === this.trueValue
      return value
    },
    __save() {
      if (this.changed()) {
        if (this.save) {
          return this.save(this)
        }
        if (this.model) {
          this.$uci.set(this.config, this.sid, this.name, this.trueValue)
					console.log('gaswdaw')
        } 
				else {
          this.$uci.set(this.config, this.sid, this.name, this.falseValue)
        }
      }
			if (!this.uciSection[this.name] && this.defaultValue){
          this.$uci.set(this.config, this.sid, this.name, this.defaultValue)					
			}
    }
  }
}
</script>
