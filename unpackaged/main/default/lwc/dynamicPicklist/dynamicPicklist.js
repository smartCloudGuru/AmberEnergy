/**
 * Created by ukaya01 on 9/20/2021.
 */

import { LightningElement, track, wire, api } from 'lwc';
import { getPicklistValuesByRecordType } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubSub';

export default class DynamicPicklist extends LightningElement {

    @wire(CurrentPageReference) pageRef;

        @api objectApiName;
        @api pickListFieldApiName;
        @api label;
        @api variant;
        @api required;

        /*only for lwc for mapping values in list and
        also for mapping this with dependent picklist(give unique = record Id while using in dependent picklist)*/
        @api uniqueKey;

        value;
        recordTypeIdValue;

        options = [];

        @api
        get recordTypeId() {
            return this.recordTypeIdValue;
        }
        set recordTypeId(value) {
            this.recordTypeIdValue = value;
        }

        @api
        get selectedValue() {
            return this.value;
        }
        set selectedValue(val) {
            if (val === '' || val === undefined || val === null)
                this.value = { label: '--None--', value: "" }.value;
            else
                this.value = val;
        }


        @wire(getObjectInfo, { objectApiName: '$objectApiName' })
        getRecordTypeId({ error, data }) {
            if (data) {
                this.record = data;
                this.error = undefined;
                if(this.recordTypeId === undefined){
                    this.recordTypeId = this.record.defaultRecordTypeId;
                }
            } else if (error) {
                this.error = error;
                this.record = undefined;
            }
        }

        @wire(getPicklistValuesByRecordType, { recordTypeId: '$recordTypeId', objectApiName: '$objectApiName' })
        wiredOptions({ error, data }) {
            if (data) {
                this.record = data;
                this.error = undefined;

                if(this.record.picklistFieldValues[this.pickListFieldApiName] !== undefined) {

                    let tempOptions = [{ label: '--None--', value: "" }];
                    let temp2Options = this.record.picklistFieldValues[this.pickListFieldApiName].values;
                    temp2Options.forEach(opt => tempOptions.push(opt));

                    this.options = tempOptions;
                }

                if(this.selectedValue === '' || this.selectedValue === undefined || this.selectedValue === null) {
                    this.value = { label: '--None--', value: "" }.value;
                } else {
                    this.value = this.options.find(listItem => listItem.value === this.selectedValue).value;
                }
            } else if (error) {
                this.error = error;
                this.record = undefined;
            }
        }


        handleChange(event) {
            let tempValue = event.target.value;
            let selectedValue = tempValue;
            let key = this.uniqueKey;

            //Firing change event for aura container to handle
            //For Self
            const pickValueChangeEvent = new CustomEvent('picklistchange', {
                detail: { selectedValue, key },
            });
            this.dispatchEvent(pickValueChangeEvent);

            //For dependent picklist
            let eventValues = {selValue : selectedValue, uniqueFieldKey: `${this.pickListFieldApiName}${this.uniqueKey}`};
            //Fire Pub/Sub Event, So that every other comp in the page knows the change
            fireEvent(this.pageRef, 'controllingValue', eventValues);
        }

}