/**
 * Created by ukaya01 on 9/22/2021.
 */

import { LightningElement, api } from 'lwc';

export default class DynamicModal extends LightningElement {

    @api showPositive;
    @api showNegative;
    @api positiveButtonLabel = 'Save';
    @api negativeButtonLabel = 'Cancel';
    @api showModal;

    constructor() {
        super();
        this.showNegative = true;
        this.showPositive = true;
        this.showModal = false;
    }

    handlePositive() {
        this.dispatchEvent(new CustomEvent('positive'));
    }

    handleNegative() {
        this.dispatchEvent(new CustomEvent('negative'));
    }

    handleClose() {
        this.dispatchEvent(new CustomEvent('close'));
    }

}