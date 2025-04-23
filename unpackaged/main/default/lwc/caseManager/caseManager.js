/**
 * Created by ukaya01 on 9/20/2021.
 */

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, api } from 'lwc';
import retrieveCaseRecords from '@salesforce/apex/CaseManagerController.retrieveCaseRecords';
import updateCaseRecords from '@salesforce/apex/CaseManagerController.updateCaseRecords';
import search from '@salesforce/apex/DynamicLookupController.search';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/

export default class CaseManager extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/
    @api filters ='OwnerId = \'00G0J0000039a65UAA\' AND RecordTypeId = \'0120J000000R33JQAS\' AND IsClosed = false';
    @api orderBy ='CreatedDate ASC';
    @api limit = 25;

    ownerFields = ['User.Name'];
    contactFields = ['Contact.Name'];
    siteFields = ['Site__c.Name'];
    caseList = [];
    error;
    isLoaded = false;
    newRecordOptions = [];
    errors = [];
    isMultiEntry = false;
    toggleSaveLabel = 'Save';


    //Variables to control modal window
    showModal = false;
    showNegativeButton = false;
    showPositiveButton = true;
    positiveButtonLabel = 'Close';

    //pagination
    page = 1;
    startingRecord = 1;
    endingRecord = 0;
    totalRecountCount = 0;
    totalPage = 0;

    /* ==============================================================================================================*/
    /* Getter & Setter
    /* ==============================================================================================================*/

    /* ==============================================================================================================*/
    /* Wired Calls
    /* ==============================================================================================================*/

    /* ==============================================================================================================*/
    /* Api Methods
    /* ==============================================================================================================*/

    /* ==============================================================================================================*/
    /* Lifecycle Hooks
    /* ==============================================================================================================*/

    connectedCallback(){
        this._retrieveCaseRecords();
    }

    /* ==============================================================================================================*/
    /* Event Handlers
    /* ==============================================================================================================*/

    handleSubjectChange(event){
        let element = this.caseList.find(ele  => ele.Id === event.target.dataset.id);
        element.Subject = event.target.value;
        element.rowStyle = 'slds-hint-parent modifiedRow';
        this.caseList = [...this.caseList];
    }

    handleEmailChange(event){
        let element = this.caseList.find(ele  => ele.Id === event.target.dataset.id);
        element.SuppliedEmail = event.target.value;
        element.rowStyle = 'slds-hint-parent modifiedRow';
        this.caseList = [...this.caseList];
    }

    handlePicklistChange(event){
        let eventData = event.detail;
        let pickValue = event.detail.selectedValue;
        let fieldName = event.target.name;
        let uniqueKey = event.detail.key;

        let element = this.caseList.find(ele  => ele.Id === uniqueKey);
        element[fieldName] = pickValue;
        element.rowStyle = 'slds-hint-parent modifiedRow';
        this.caseList = [...this.caseList];
    }

    handleLookupSelection(event){
        let eventData = event.detail;
        let id = event.detail.selectedId;
        let uniqueKey = event.detail.key;
        let fieldName = event.target.name;

        let element = this.caseList.find(ele  => ele.Id === uniqueKey);
        element.rowStyle = 'slds-hint-parent modifiedRow';
        element[fieldName] = id;
        this.caseList = [...this.caseList];
    }

    handleRefresh(){
        this.isLoaded = false;
        this._retrieveCaseRecords();
    }

    handleSave() {
        this.isLoaded = false;
        this.toggleSaveLabel = 'Saving...'
        let toSaveList = [];
        this.caseList.forEach((element, index) => {
            if(element.Id.length > 0 && element.rowStyle.includes("modifiedRow")){
                if(this._validateMandatoryFields(element) === false){
                    this.isLoaded = true;
                    this.toggleSaveLabel = 'Save'
                }else{
                    let record = {};
                    record.Id = element.Id ? element.Id : '';
                    record.Subject = element.Subject ? element.Subject : '';
                    record.OwnerId = element.OwnerId ? element.OwnerId : '';
                    record.Status = element.Status ? element.Status : '';
                    record.ContactId = element.ContactId ? element.ContactId : '';
                    record.Reason = element.Reason ? element.Reason : '';
                    record.Priority = element.Priority ? element.Priority : '';
                    record.Landlord_Resident__c = element.Landlord_Resident__c ? element.Landlord_Resident__c : '';
                    record.Site__c = element.SiteId ? element.SiteId : '';
                    record.SuppliedEmail = element.SuppliedEmail ? element.SuppliedEmail : '';
                    toSaveList.push(record);
                }
            }

        });

        if(toSaveList.length > 0){
            updateCaseRecords({records: JSON.stringify(toSaveList), filter: this.filters, orderBy: this.orderBy}).then(result => {
                let records = this._formatCaseRecords(result);
                this._initializeTable(records);
                this.error = undefined;
            }).catch(error => {
                this.error = error;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title : 'Save Error',
                        message : error.body.message,
                        variant : 'error',
                    }),
                );
            }).finally(() => {
                this.isLoaded = true;
                this.toggleSaveLabel = 'Save';
            });
        }else{
            this.isLoaded = true;
            this.toggleSaveLabel = 'Save';
        }

    }

    handleSearchOwner(event){
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        let params = event.detail;
        let searchParameters = [];
        searchParameters.push( {"objectName" : "User", "filters" : "", "icon" : "standard:user"});
        searchParameters.push( {"objectName" : "Group", "filters" : "Type = 'Queue'", "icon" : "standard:groups"});
        params.searchParams = JSON.stringify(searchParameters);
        this._handleLookupSearch(params, lookupElement);
    }

    handleSearchContact(event){
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        let params = event.detail;
        let searchParameters = [];
        searchParameters.push( {"objectName" : "Contact", "filters" : "", "icon" : "standard:contact"});
        params.searchParams = JSON.stringify(searchParameters);
        this._handleLookupSearch(params, lookupElement);
    }

    handleSearchSite(event){
        const lookupElement = event.target;
        // Call Apex endpoint to search for records and pass results to the lookup
        let params = event.detail;
        let searchParameters = [];
        searchParameters.push( {"objectName" : "Site__c", "filters" : "", "icon" : "custom:custom16"});
        params.searchParams = JSON.stringify(searchParameters);
        this._handleLookupSearch(params, lookupElement);
    }

    handleLookupOwnerSelectionChange(event){
        let selection = JSON.parse(JSON.stringify(event.detail));
        let uniqueKey = event.target.name;
        let element = this.caseList.find(ele  => ele.Id === uniqueKey);
        if(selection === null || selection === undefined || selection === [] || selection.length === 0){
            selection = [{ 'id' : '', title : ''}];
            element.InitialSelectionOwner = [];
        }else{
            element.InitialSelectionOwner = [
                {
                    id: selection[0].id,
                    sObjectType: 'Group',
                    icon: 'standard:groups',
                    title: selection[0].title,
                    subtitle: ''
                }
            ];
        }
        element.OwnerId = selection[0].id;
        element.OwnerName = selection[0].title;
        element.Owner.Id = selection[0].id;
        element.Owner.Name = selection[0].title;
        element.rowStyle = 'slds-hint-parent modifiedRow';

        this.caseList = [...this.caseList];
    }

    handleLookupContactSelectionChange(event){
        let selection = JSON.parse(JSON.stringify(event.detail));
        let uniqueKey = event.target.name;
        let element = this.caseList.find(ele  => ele.Id === uniqueKey);
        if(selection === null || selection === undefined || selection === [] || selection.length === 0){
            selection = [{ 'id' : '', title : ''}];
            element.InitialSelectionContact = [];
        }else{
            element.InitialSelectionContact = [
                {
                    id: selection[0].id,
                    sObjectType: 'Contact',
                    icon: 'standard:contact',
                    title: selection[0].title,
                    subtitle: ''
                }
            ];
        }
        element.ContactId = selection[0].id;
        element.ContactName = selection[0].title;
        element.Contact.Id = selection[0].id;
        element.Contact.Name = selection[0].title;
        element.rowStyle = 'slds-hint-parent modifiedRow';

        this.caseList = [...this.caseList];
    }

    handleLookupSiteSelectionChange(event){
        let selection = JSON.parse(JSON.stringify(event.detail));
        let uniqueKey = event.target.name;
        let element = this.caseList.find(ele  => ele.Id === uniqueKey);
        if(selection === null || selection === undefined || selection === [] || selection.length === 0){
            selection = [{ 'id' : '', title : ''}];
            element.InitialSelectionSite = [];
        }else{
            element.InitialSelectionSite = [
                {
                    id: selection[0].id,
                    sObjectType: 'Site__c',
                    icon: 'custom:custom16',
                    title: selection[0].title,
                    subtitle: ''
                }
            ];
        }
        element.SiteId = selection[0].id;
        element.SiteName = selection[0].title;
        element.Site__r.Id = selection[0].id;
        element.Site__r.Name = selection[0].title;
        element.rowStyle = 'slds-hint-parent modifiedRow';

        this.caseList = [...this.caseList];
    }

    handleEmailDisplay(event){
        let indexPosition = event.currentTarget.name;
        const recordId = event.currentTarget.dataset.id;
        let element = this.caseList.find(ele  => ele.Id === recordId);
        this.emailMessages = element.EmailMessages;
        this._showModalPopup();
    }

    closeModal() {
        this.showModal = false;
    }

    //clicking on previous button this method will be called
    handlePreviousPage() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this._displayRecordPerPage(this.page);
        }
    }

    //clicking on next button this method will be called
    handleNextPage() {
        if((this.page<this.totalPage) && this.page !== this.totalPage){
            this.page = this.page + 1; //increase page by 1
            this._displayRecordPerPage(this.page);
        }
    }

    //this method displays records page by page
    _displayRecordPerPage(page){

        this.startingRecord = ((page -1) * this.limit) ;
        this.endingRecord = (this.limit * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount)
                            ? this.totalRecountCount : this.endingRecord;

        this.caseList = this.allRecords.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
    }

    /* ==============================================================================================================*/
    /* Helper Methods
    /* ==============================================================================================================*/

    _retrieveCaseRecords(){
        retrieveCaseRecords({filter: this.filters, orderBy: this.orderBy}).then(result => {

            let records = this._formatCaseRecords(result);
            this._initializeTable(records);
            this.error = undefined;
        }).catch(error => {
            console.error(error);
            this.error = error;
            this.caseList = [];
        }).finally(() => {
            this.isLoaded = true;
        });
    }

    _initializeTable(records){
        this.allRecords = records;
        this.totalRecountCount = this.allRecords.length;
        this.totalPage = Math.ceil(this.totalRecountCount / this.limit);

        this.caseList = this.allRecords.slice(0,this.limit);
        this.endingRecord = this.limit;
    }

    _formatCaseRecords(records){
        for(let i = 0; i < records.length; i++) {
            if(records[i].Id){
                records[i].recordUrl = `/${records[i].Id}`;
            }
            if(records[i].Owner){
                records[i].OwnerId = records[i].Owner.Id;
                records[i].OwnerName = records[i].Owner.Name;
                records[i].InitialSelectionOwner = [
                    {
                        id: records[i].OwnerId,
                        sObjectType: 'Group',
                        icon: 'standard:groups',
                        title: records[i].OwnerName,
                        subtitle: ''
                    }
                ];
            }else{
                records[i].Owner = {};
                records[i].InitialSelectionOwner = [];
            }

            if(records[i].Site__r){
                records[i].SiteId = records[i].Site__r.Id;
                records[i].SiteName = records[i].Site__r.Name;
                records[i].InitialSelectionSite = [
                    {
                        id: records[i].SiteId,
                        sObjectType: 'Site__c',
                        icon: 'custom:custom16',
                        title: records[i].SiteName,
                        subtitle: ''
                    }
                ];
            }else{
                records[i].Site__r = {};
                records[i].InitialSelectionSite = [];
            }

            if(records[i].Contact){
                records[i].ContactId = records[i].Contact.Id;
                records[i].ContactName = records[i].Contact.Name;
                records[i].InitialSelectionContact = [
                    {
                        id: records[i].ContactId,
                        sObjectType: 'Contact',
                        icon: 'standard:contact',
                        title: records[i].ContactName,
                        subtitle: ''
                    }
                ];
            }else{
                records[i].Contact = {};
                records[i].InitialSelectionContact = [];
            }

            records[i].rowStyle = 'slds-hint-parent default';
        }
        return records;
    }

    _handleLookupSearch(params, lookupElement){

        search(params)
            .then((results) => {
                lookupElement.setSearchResults(results);
            })
            .catch((error) => {
                //this.notifyUser('Lookup Error', 'An error occured while searching with the lookup field.', 'error');
                // eslint-disable-next-line no-console
                console.error('Lookup error', JSON.stringify(error));
                this.errors = [error];
            });
    }

    _showModalPopup() {
        this.showModal = true;
    }

    _validateMandatoryFields(record){
        let valid = true;
        if(record.Reason === ''){
            this._fireValidationError('Case Reason');
            valid = false;
        }else if(record.Landlord_Resident__c === ''){
            this._fireValidationError('Landlord or Resident');
            valid = false;
        }else if(record.SiteId === ''){
            this._fireValidationError('Site');
            valid = false;
        }else if(record.OwnerId === ''){
            this._fireValidationError('Owner');
            valid = false;
        }
        return valid;
    }

    _fireValidationError(fieldName){
        this.dispatchEvent(
            new ShowToastEvent({
                title : 'Validation Error',
                message : `Please fill ` + fieldName,
                variant : 'error',
            }),
        );
    }

}