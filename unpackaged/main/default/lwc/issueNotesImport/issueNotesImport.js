/**
  * @Author:      Ugur K.
  * @Company:     Freelance
  * @Description: Component to import csv file to create Notes for the related issues
  * @Date:        25-02-2021
  * History
  * <Date>      <Authors Name>     <Brief Description of Change>
  *
 **/

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, api, wire } from 'lwc';
import convertCSV from '@salesforce/apex/IssueNotesImportController.convertCSV';
import processRecords from '@salesforce/apex/IssueNotesImportController.processRecords';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

/* ==============================================================================================================*/
/* External Resources
/* ==============================================================================================================*/
import templateResource from '@salesforce/resourceUrl/IssueNoteImportResources';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/

export default class IssueNotesImport extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/
    MAX_FILE_SIZE = 1000000; //1 megabyte
    CHUNK = 25;
    showSpinner = false;
    filesProcessed = false;
    templateUrl = templateResource + '/import/Template.csv';
    progress = 0;
    isProgressing = false;
    displayImportResult = false;

    fileReader;
    filesUploaded = [];
    file;
    fileContents;
    fileReader;
    content;
    fileName = '';
    csvRecords = [];

    headers = {
        'meterRef' : "Meter Ref",
        'title' : "Title",
        'note' : "Note",
        'status' : "Status"
    }

    importResult;

    /* ==============================================================================================================*/
    /* Getter & Setter
    /* ==============================================================================================================*/

    get isImportButtonDisabled(){
        if(this.filesUploaded.length === 0 || this.isProgressing === true){
            return true;
        }else{
            return false;
        }
    }

    get systemErrorsExist(){
        if(this.importResult.systemErrorCount > 0){
            return true;
        }else{
            return false;
        }
    }

    get totalRecordSize(){
        return this.csvRecords.length;
    }

    get importIcon(){
        if(this.isProgressing === true){
            return 'action:user_activation';
        }else{
            return 'action:check';
        }
    }

    /* ==============================================================================================================*/
    /* Wired Calls
    /* ==============================================================================================================*/

    /* ==============================================================================================================*/
    /* Api Methods
    /* ==============================================================================================================*/

    /* ==============================================================================================================*/
    /* Lifecycle Hooks
    /* ==============================================================================================================*/

    connectedCallBack(){
        this._resetImportResult();
    }

    /* ==============================================================================================================*/
    /* Event Handlers
    /* ==============================================================================================================*/

    handleFilesChange(event){
        if(event.target.files.length > 0) {
            this.filesUploaded = event.target.files;
            this.fileName = event.target.files[0].name;
            this.filesProcessed = false;
            this._resetImportResult();
            if(this._checkFileSize() === false){
                this.filesUploaded = [];
            }
        }
    }

    handleStartImport(){
        this._processFile();
    }

    downloadCsv(){

        // get the Records
        var data = this.importResult.data;

        //call the helper function which "return" the CSV data as a String
        var csv = this._convertArrayOfObjectsToCSV(data);
        if(csv === null){
            return;
        }

        // Creating anchor element to download
        let downloadElement = document.createElement('a');
        // This  encodeURI encodes special characters, except: , / ? : @ & = + $ # (Use encodeURIComponent() to encode these characters).
        downloadElement.href = 'data:text/csv;charset=utf-8,' + encodeURI(csv);
        downloadElement.target = '_self';
        downloadElement.download = 'ImportResult.csv';
        document.body.appendChild(downloadElement);
        downloadElement.click();

    }

    /* ==============================================================================================================*/
    /* Helper Methods
    /* ==============================================================================================================*/

    _resetImportResult(){
        this.importResult = {
            "data" : [],
            "recordCount" : 0,
            "successCount" : 0,
            "missingIssueCount" : 0,
            "multipleIssueCount" : 0,
            "systemErrorCount" : 0
        }
        this.displayImportResult = false;
    }

    _checkFileSize(){
        this.file = this.filesUploaded[0];

        if(this.file.size > this.MAX_FILE_SIZE) {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'File Size is too big',
                    variant: 'error',
                }),
            );
            console.error('File Size is too big');
            return false;
        }else{
            return true;
        }
    }

    _processFile() {

        this.showSpinner = true;
        this.isProgressing = true;
        this.fileReader= new FileReader();
        this.fileReader.onloadend = (() => {
           this.fileContents = this.fileReader.result;
           this._saveRecords();
        });
        this.fileReader.readAsText(this.file);

    }

    _saveRecords(){
        convertCSV({'base64' : JSON.stringify(this.fileContents)}).then(result => {
            this.csvRecords = result;
            this._processNextBatch(0);
        }).catch(error => {
            this.filesUploaded = [];
            this.showSpinner = false;
            console.error(error);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while uploading File',
                    message: error.message,
                    variant: 'error',
                }),
            );
        });
    }

    _processNextBatch(index){
        this.progress = (index/this.csvRecords.length)*100;
        if(index < this.csvRecords.length){
            var batch = this.csvRecords.slice(index,index+this.CHUNK);
            this._processRecords(batch,index);
        }else{
            this.importResult.data = this.csvRecords;
            this.filesProcessed = true;
            this.showSpinner = false;
            this.isProgressing = false;
        }

    }

    _processRecords(batch,index){

        processRecords({'notes' : JSON.stringify(batch)}).then(result => {
            this.filesUploaded = [];
            result.forEach(row => {
                this.importResult.recordCount += 1;
                if(row.status === 'Success'){
                    this.importResult.successCount += 1;
                }else if(row.status === 'No Open Issue found for the given meter reference'){
                    this.importResult.missingIssueCount += 1;
                }else if(row.status === 'More than one issue found the given meter reference'){
                    this.importResult.multipleIssueCount += 1;
                }else if(row.status.startsWith("Error")){
                    this.importResult.systemErrorCount += 1;
                }
                this.csvRecords[row.index-1].status = row.status;
            });
        }).catch(error => {
            console.error(error);
        }).finally(() => {
            this.showSpinner = false;
            this.displayImportResult = true;
            this._processNextBatch(index+this.CHUNK);
        });

    }

    _convertArrayOfObjectsToCSV(objectRecords){

        var csvStringResult, counter, keys, columnDivider, lineDivider;

        if (objectRecords == null || !objectRecords.length) {
            return null;
         }

        // store ,[comma] in columnDivider variable for separate CSV values and
        // for start next line use '\n' [new line] in lineDivider variable
        columnDivider = ',';
        lineDivider =  '\n';

        keys = Object.keys(this.headers);
        const headerToShow = Object.values(this.headers);

        csvStringResult = '';
        csvStringResult += headerToShow.join(columnDivider);
        csvStringResult += lineDivider;

        for(var i=0; i < objectRecords.length; i++){
            counter = 0;

            for(var sTempkey in keys) {
                var skey = keys[sTempkey] ;

                // add , [comma] after every String value,. [except first]
                if(counter > 0){
                    csvStringResult += columnDivider;
                }

                csvStringResult += '"'+ objectRecords[i][skey]+'"';
                counter++;

            }
            csvStringResult += lineDivider;
        }

        return csvStringResult;
    }


}