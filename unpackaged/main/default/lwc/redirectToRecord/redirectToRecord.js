import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class RedirectToRecord extends NavigationMixin(LightningElement) {
    @api recordId; 
    @api objectApiName;

    handleRedirect() {
        console.debug('record id debug: ', this.recordId);
        window.location.href = `${window.location.href.split('/s/')[0]}/s/${encodeURIComponent(this.objectApiName).toLowerCase()}/${encodeURIComponent(this.recordId)}`;
    }

    renderedCallback(){
        this.handleRedirect();
    }
}